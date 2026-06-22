import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memory_game/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/premium_constant.dart';
import 'package:memory_game/constant/text_style.dart';
import 'package:memory_game/domain/growth.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/state/activity_log_state.dart';
import 'package:memory_game/state/app_info_state.dart';
import 'package:memory_game/services/admob.dart';
import 'package:memory_game/services/premium_service.dart';
import 'package:memory_game/state/item_table_info_state.dart';
import 'package:memory_game/state/level_infos_state.dart';
import 'package:memory_game/view/app_menu_drawer.dart';
import 'package:memory_game/view/memorize.dart';
import 'package:memory_game/view/notification_prompt.dart';
import 'package:memory_game/view/paywall.dart';
import 'package:memory_game/view/record.dart';
import 'package:memory_game/view/util/pressable.dart';
import 'package:memory_game/view/util/util.dart';
import 'package:memory_game/view/util/widget.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  // 通知の許可プロンプトを当セッションで一度だけ確認するためのフラグ。
  bool _notifPromptChecked = false;

  @override
  Widget build(BuildContext context) {
    final gameLevel = ref.watch(gameLevelProvider);
    final levelInfos = ref.watch(levelInfosProvider);
    final activityLog = ref.watch(activityLogProvider);

    // 初回プレイ後（記録ができてから）に限り、通知の説明→許可を一度だけ促す。
    // ゲーム直後は結果画面が前面にあるため、ホームが最前面のときだけ表示する。
    if (!_notifPromptChecked && activityLog.activeDayCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final route = ModalRoute.of(context);
        if (route == null || !route.isCurrent) return;
        _notifPromptChecked = true;
        maybeShowNotificationPrompt(context);
      });
    }

    //表示するベストタイムを設定
    final records = levelInfos[gameLevel].recordInfos;

    // 直近にクリアしたタイム（=最も新しい記録）がランキングのどの順位かを
    // 特定し、「前回の記録」ラベルで強調表示する。
    int lastRecordIndex = -1;
    DateTime? latestDate;
    for (int i = 0; i < records.length; i++) {
      final date = records[i].recordedDate;
      if (latestDate == null || date.isAfter(latestDate)) {
        latestDate = date;
        lastRecordIndex = i;
      }
    }

    List<Widget> memorizeTimes = [];
    for (int i = 0; i < records.length; i++) {
      final isLastRecord = i == lastRecordIndex;
      memorizeTimes.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            // 「順位＋タイム」と「日付」を行で分け、バッジが付いても
            // 末尾が省略（…）されないようにする。
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        " ${i + 1}.   ${getFormattedTime(records[i].memorizeTime)} ${AppLocalizations.of(context)!.homeRecordUnit}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.record,
                      ),
                    ),
                    //直近の記録には「前回の記録」ラベルを付ける
                    if (isLastRecord) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: DefColor.select,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.homeLastRecord,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.badge,
                        ),
                      ),
                    ],
                  ],
                ),
                //日付は次の行に控えめに添える
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 1),
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(records[i].recordedDate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.recordDate,
                  ),
                ),
              ],
            ),
          ),
          Container(
              padding: const EdgeInsets.all(10.0),
              height: 5.0,
              decoration: BoxDecoration(
                color: DefColor.darkBeige,
                borderRadius: BorderRadius.circular(10),
              ))
        ],
      ));
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: DefColor.lightBeige,
        drawer: const AppMenuDrawer(),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fixedHeight = 104 +
                  32 +
                  58 + // 記録画面への導線ボタン（右上の丸ボタン）ぶん
                  context.levelSelectHeight +
                  context.buttonHeight +
                  context.bannerReserve;
              final gaps = context.sectionGap * 6;
              final recordHeight = (constraints.maxHeight - fixedHeight - gaps)
                  .clamp(120.0, 260.0);

              return Stack(
                children: [
                  Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: context.pagePadding),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: context.contentMaxWidth),
                        child: Column(
                          children: [
                            SizedBox(height: context.sectionGap),
                            //上部の導線（左：メニュー／中央：プレミアム／右：記録画面）
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const MenuButton(),
                                //無料ユーザーにはプレミアム（広告非表示）への導線を出す。
                                const PremiumBadgeButton(),
                                RecordsButton(
                                  label: AppLocalizations.of(context)!
                                      .homeRecordButton,
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RecordView()),
                                  ),
                                ),
                              ],
                            ),
                            //タイトル
                            Text(
                              AppLocalizations.of(context)!.homeGameTitle,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.title,
                            ),
                            SizedBox(height: context.sectionGap),
                            //ベストタイム
                            Text(
                              "Level ${gameLevel + 1} Best Time",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.subheading,
                            ),
                            //タイム
                            //育成: 相棒は表の上端に頭を合わせ、表の中に収めず背後に
                            //大きく表示する（下方向へはみ出し、下のボタン類が手前に重なる）。
                            Stack(clipBehavior: Clip.none, children: [
                              // 選択中レベルに記録がない（＝そのレベルを一度も
                              // クリアしていない）うちは相棒を出さない。
                              if (records.isNotEmpty)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  // 枠の高さを表（＋すこし下）に抑える。大きな枠だと
                                  // 相棒が枠いっぱいに広がって重心が画面中央に寄り、
                                  // 「中央配置」に見えてしまうため。頭は表の上端のまま。
                                  height: recordHeight + context.sectionGap,
                                  child: IgnorePointer(
                                    child: Opacity(
                                      opacity: 0.28,
                                      child: SvgPicture.asset(
                                        growthAssetPath(
                                            gameLevel,
                                            stageForExp(
                                                    levelInfos[gameLevel].exp)
                                                .index),
                                        fit: BoxFit.contain,
                                        alignment: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                ),
                              Container(
                                width: context.contentWidth,
                                height: recordHeight,
                                padding: const EdgeInsets.all(3.0),
                                decoration: BoxDecoration(
                                  // 背景は透過にして、裏側のランク画像が見えるようにする。
                                  color: DefColor.none,
                                  border: Border.all(
                                      color: DefColor.darkBeige, width: 4.0),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: memorizeTimes.isEmpty
                                    //記録がなければメッセージ表示
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            levelInfos[gameLevel].isLocked
                                                //レベルがロックされている場合のメッセージ
                                                ? AppLocalizations.of(context)!
                                                    .homeLockedLevel
                                                //記録がない場合のメッセージ
                                                : AppLocalizations.of(context)!
                                                    .homeNoRecords,
                                            style: AppText.body,
                                          ),
                                        ),
                                      )
                                    //記録がある場合は記録を表示
                                    : Scrollbar(
                                        thumbVisibility: true,
                                        child: Padding(
                                          padding: const EdgeInsets.all(7.0),
                                          child:
                                              ListView(children: memorizeTimes),
                                        ),
                                      ),
                              ),
                            ]),
                            SizedBox(height: context.sectionGap),
                            //レベル選択ピッカー
                            LevelSelect(
                                level: gameLevel,
                                lockedLevel: getLockedLevel(levelInfos),
                                onPressed: (level) {
                                  ref
                                      .read(gameLevelProvider.notifier)
                                      .select(level);
                                }),
                            SizedBox(height: context.sectionGap),
                            //スタートボタン
                            MyTextButton(
                              onPressed: levelInfos[gameLevel].isLocked
                                  ? null
                                  : () {
                                      final gameLevel =
                                          ref.read(gameLevelProvider);

                                      //このレベルを「前回プレイしたレベル」として
                                      //永続化し、次回起動時に選択状態を復元する。
                                      ref
                                          .read(gameLevelProvider.notifier)
                                          .persist();

                                      //テーブルを生成
                                      ref
                                          .read(itemTableInfoProvider.notifier)
                                          .createTableItems(gameLevel);

                                      //記憶画面へ遷移。ゲームから戻ったら
                                      //再描画し、必要なら通知プロンプトを出す。
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MemorizeView()),
                                      ).then((_) {
                                        if (mounted) setState(() {});
                                      });
                                    },
                              text: "Start",
                            ),
                            const Spacer(),
                            //バナー
                            const AdmobBannerWidget(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ホーム左上のメニューボタン。記録ボタンと同じ「darkBlue の凹む立体丸ボタン」で
// 統一し、タップでサイドメニュー（AppMenuDrawer）を開く。
class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final size = context.homeButtonSize;
    const depth = 5.0;
    return Tooltip(
      message: AppLocalizations.of(context)!.menuTitle,
      child: SizedBox(
        width: size,
        height: size + depth,
        child: PressableButton(
          shape: BoxShape.circle,
          depth: depth,
          color: DefColor.darkBlue,
          haptic: PressHaptic.medium,
          // メニューボタンは Scaffold の drawer を開く。context は Scaffold の
          // 子孫なので Scaffold.of がそのまま使える。
          onPressed: () => Scaffold.of(context).openDrawer(),
          child: const Icon(
            Icons.menu_rounded,
            color: DefColor.textWhite,
            size: 26,
          ),
        ),
      ),
    );
  }
}

// 無料ユーザーへ向けた、ホーム上部のプレミアム（広告非表示）導線。
// 既存の丸ボタンと同じ立体表現で、目を引くゴールド（王冠）にして区別する。
// プレミアム会員・課金非対応プラットフォームでは表示しない（spaceBetween の
// レイアウトを崩さないよう、その場合は幅0で畳む）。
class PremiumBadgeButton extends StatelessWidget {
  const PremiumBadgeButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!iapSupported) return const SizedBox.shrink();
    return ValueListenableBuilder<bool>(
      valueListenable: PremiumService.instance.isPremium,
      builder: (context, isPremium, _) {
        if (isPremium) return const SizedBox.shrink();
        final size = context.homeButtonSize;
        const depth = 5.0;
        return Tooltip(
          message: AppLocalizations.of(context)!.premiumMenuLabel,
          child: SizedBox(
            width: size,
            height: size + depth,
            child: PressableButton(
              shape: BoxShape.circle,
              depth: depth,
              color: DefColor.select,
              edgeColor: DefColor.selectDeep,
              haptic: PressHaptic.medium,
              onPressed: () => showPaywall(context),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: DefColor.textWhite,
                size: 26,
              ),
            ),
          ),
        );
      },
    );
  }
}

// 記録画面（連続日数・カレンダー）へ移動する、右上の小さな円形アイコンボタン。
// ホームボタン（Icons.home）と同じ「darkBlue の凹む立体丸ボタン」で統一する。
class RecordsButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const RecordsButton(
      {required this.label, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    final size = context.homeButtonSize;
    const depth = 5.0;
    return Tooltip(
      message: label,
      child: SizedBox(
        width: size,
        height: size + depth,
        child: PressableButton(
          shape: BoxShape.circle,
          depth: depth,
          color: DefColor.darkBlue,
          haptic: PressHaptic.medium,
          onPressed: onPressed,
          child: const Icon(
            Icons.calendar_month,
            color: DefColor.textWhite,
            size: 26,
          ),
        ),
      ),
    );
  }
}
