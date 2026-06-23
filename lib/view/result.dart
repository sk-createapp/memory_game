import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memory_game/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/result_messages.dart';
import 'package:memory_game/constant/text_style.dart';
import 'package:memory_game/domain/growth.dart';
import 'package:memory_game/model/item_table_info.dart';
import 'package:memory_game/state/level_infos_state.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/state/activity_log_state.dart';
import 'package:memory_game/state/app_info_state.dart';
import 'package:memory_game/services/admob.dart';
import 'package:memory_game/services/premium_service.dart';
import 'package:memory_game/services/review_service.dart';
import 'package:memory_game/services/sound_service.dart';
import 'package:memory_game/state/game_info_state.dart';
import 'package:memory_game/state/item_table_info_state.dart';
import 'package:memory_game/view/paywall.dart';
import 'package:memory_game/view/util/confetti.dart';
import 'package:memory_game/view/util/pressable.dart';
import 'package:memory_game/view/util/util.dart';
import 'package:memory_game/view/util/widget.dart';

class ResultView extends ConsumerStatefulWidget {
  // 今回のタイムが自己ベストを更新したか（全問正解時のみ意味を持つ）。
  final bool isNewRecord;
  // 今回のクリアで得た育成EXPの結果（クリア時のみ）。
  // EXPの数値・バーは画面に出さないが、段階アップ時の演出（音・紙吹雪）に使う。
  final GrowthGain? growthGain;

  const ResultView({this.isNewRecord = false, this.growthGain, super.key});

  @override
  ConsumerState<ResultView> createState() => _AnswerViewState();
}

class _AnswerViewState extends ConsumerState<ResultView> {
  bool _celebrated = false;

  // 吹き出しメッセージは画面表示ごとに1つだけ決め、
  // 正解アイテムをめくる等の再描画では変わらないよう固定する。
  final int _messageSeed = Random().nextInt(1 << 31);

  @override
  void initState() {
    super.initState();
    // 結果画面の表示はゲーム1回ぶんの完了に相当する。
    // 継続記録へ「今日のプレイ」を1回ぶん記録する（クリア時はクリア回数を加算）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final itemTableInfo = ref.read(itemTableInfoProvider);
      final cleared =
          isAllCorrect(itemTableInfo.tableItems, itemTableInfo.answerItemNum);
      ref.read(activityLogProvider.notifier).recordPlay(cleared: cleared);

      final newRecord = cleared && widget.isNewRecord;

      // 結果に応じた効果音を鳴らす。失敗はやさしい残念音、クリアはジングル＋拍手、
      // 新記録のときだけ華やかなファンファーレ＋歓声で祝う。
      // 段階アップは紙吹雪（視覚）で祝い、音は新記録専用にして混同を防ぐ。
      // （設定でオフなら SoundService 側で無音になる）
      if (!cleared) {
        SoundService.instance.playResult(ResultSound.failure);
      } else if (newRecord) {
        SoundService.instance.playResult(ResultSound.fanfare);
      } else {
        SoundService.instance.playResult(ResultSound.clear);
      }

      // 自己ベスト更新（達成感のピーク＝最も高評価をつけたくなる瞬間）に、
      // 条件を満たせばストアレビューを依頼する。新記録バナーや紙吹雪の余韻を
      // 味わってから出すため、少し遅らせてネイティブ依頼を呼ぶ。
      if (newRecord) {
        final clearNum = ref.read(gameInfoProvider).clearNum;
        Future.delayed(const Duration(milliseconds: 1600), () {
          ReviewService.instance.maybeRequestReviewOnAchievement(
            isNewRecord: true,
            clearNum: clearNum,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    // 結果画面を抜けるときは、念のため結果音をフェードアウトして止める
    // （通常はホームボタンの _leaveToHome で既に開始済み）。
    SoundService.instance.fadeOutResult();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemTableInfo = ref.watch(itemTableInfoProvider);
    final gameLevel = ref.watch(gameLevelProvider);

    final cleared =
        isAllCorrect(itemTableInfo.tableItems, itemTableInfo.answerItemNum);
    // 新記録は全問正解時のみ意味を持つ。
    final newRecord = cleared && widget.isNewRecord;

    // 育成: 相棒は現在の成長段階で表示する。
    // ただしEXPの数値・進捗バーはユーザーに見せない（育成はあくまで見た目の成長で表現）。
    final levelInfos = ref.watch(levelInfosProvider);
    final exp = gameLevel < levelInfos.length ? levelInfos[gameLevel].exp : 0;
    final stage = stageForExp(exp);

    //全問正解なら一度だけ達成感のある触覚フィードバックを再生する
    if (!_celebrated && cleared) {
      _celebrated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 新記録ならより強い触覚フィードバックを2連続で。
        fireHaptic(PressHaptic.heavy);
        if (newRecord) {
          Future.delayed(const Duration(milliseconds: 140),
              () => fireHaptic(PressHaptic.heavy));
        }
      });
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: DefColor.lightBeige,
        body: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 成功・失敗どちらでも吹き出しを出すため、常に高さを確保する。
                  const commentHeight = 52.0;
                  // 新記録バナーを出すぶん、上側の確保領域を広げる。
                  final tableSize = context.tableSizeFor(
                    constraints,
                    topReserve: (newRecord ? 134.0 : 72.0) + context.sectionGap,
                    bottomReserve: context.buttonHeight +
                        commentHeight +
                        context.bannerReserve +
                        context.sectionGap * 4,
                    maxWidthRatio: 0.96,
                  );

                  return Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: context.pagePadding),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: context.contentMaxWidth),
                        child: Column(
                          children: [
                            SizedBox(height: context.sectionGap),
                            //新記録バナー（自己ベスト更新時のみ、大きくポップイン）
                            if (newRecord) ...[
                              NewRecordBanner(
                                text: AppLocalizations.of(context)!
                                    .resultNewRecord,
                              ),
                              SizedBox(height: context.sectionGap),
                            ],
                            //メッセージ
                            Text(
                              getAboveMessageString(itemTableInfo, gameLevel),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.resultTitle,
                            ),
                            //タイム
                            Text(
                              getMemorizeTimeString(itemTableInfo, gameLevel),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.resultTime,
                            ),
                            SizedBox(height: context.sectionGap),
                            //アイテムテーブル
                            SizedBox.square(
                                dimension: tableSize,
                                child: CorrectAnswerTable(
                                    rowNum: itemTableInfo.rowNum,
                                    tableItems: itemTableInfo.tableItems)),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Spacer(),
                                  //ホームボタン
                                  MyTextButton(
                                      onPressed: () => _leaveToHome(context),
                                      text: "Home"),
                                  SizedBox(height: context.sectionGap),
                                  //コメント（キャラクターのしっぽ付き吹き出し）
                                  //吹き出しはテキスト量に応じて幅が伸縮する。
                                  //Expandedだと残り幅いっぱいに広がってしまい、
                                  //特にタブレットでは短い一言でも横長になって違和感が出るため、
                                  //Flexible(loose)で内容に追従させ、長文のみ最大幅で折り返す。
                                  SizedBox(
                                    height: commentHeight,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          growthAssetPath(
                                              gameLevel, stage.index),
                                          width: commentHeight,
                                          height: commentHeight,
                                        ),
                                        Flexible(
                                          child: SpeechBubble(
                                            child: Text(
                                              getResultCommentString(
                                                  itemTableInfo),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: DefColor.textBlack,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                height: 1.25,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: context.sectionGap),
                                  //バナー
                                  const AdmobBannerWidget(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // クリア時は紙吹雪を画面全体に降らせる。新記録なら8秒間しっかり降らせて
            // より派手に祝う。段階アップは専用の演出はせず、相棒の見た目が変わる
            // ことだけでそれとなく示す。
            if (cleared)
              Positioned.fill(
                child: ConfettiOverlay(
                  intense: newRecord,
                  durationSeconds: newRecord ? 8.0 : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  //ホームへ戻る。プレミアム判定 → ペイウォール（広告前の提案）→ インタースティシャル
  //広告、の順に評価し、最後に必ずホームへ戻す。
  Future<void> _leaveToHome(BuildContext context) async {
    // 結果音がまだ鳴っていれば、ホームへ戻る合図としてフェードアウトさせる。
    // フェードは SoundService 側のタイマーで進むため、画面を抜けても最後まで効く。
    SoundService.instance.fadeOutResult();

    void goHome() {
      if (!context.mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    }

    // プレミアム会員は広告・ペイウォールなしで即ホームへ。
    if (PremiumService.instance.isPremium.value) {
      goHome();
      return;
    }

    // 広告でゲーム体験が途切れる前に、十分に遊んだ無料ユーザーへ
    // プレミアム（広告非表示）を控えめに提案する。出したらホームへ。
    final totalPlays = ref.read(activityLogProvider).totalPlays;
    final shownPaywall =
        await PaywallTrigger.maybeShowBeforeAd(context, totalPlays);
    if (shownPaywall) {
      goHome();
      return;
    }

    // ペイウォールを出さないときは従来どおりインタースティシャル（頻度制御あり）。
    InterstitialAdManager.instance.maybeShow(onDone: goHome);
  }

  //画面上部に表示するメッセージ文
  String getAboveMessageString(ItemTableInfo itemTableInfo, int gameLevel) {
    String message;

    if (isAllCorrect(itemTableInfo.tableItems, itemTableInfo.answerItemNum)) {
      message = AppLocalizations.of(context)!.resultGameClear;
    } else {
      message = AppLocalizations.of(context)!.resultGameFailure;
    }

    return "Level ${gameLevel + 1} $message";
  }

  //吹き出しに表示する一言（成功＝ほめ言葉／新記録／失敗＝励まし）
  String getResultCommentString(ItemTableInfo itemTableInfo) {
    final ResultMessageKind kind;
    if (!isAllCorrect(itemTableInfo.tableItems, itemTableInfo.answerItemNum)) {
      kind = ResultMessageKind.failure;
    } else if (widget.isNewRecord) {
      kind = ResultMessageKind.newRecord;
    } else {
      kind = ResultMessageKind.praise;
    }

    return ResultMessages.pick(
      kind: kind,
      languageCode: Localizations.localeOf(context).languageCode,
      seed: _messageSeed,
    );
  }

  //タイムのテキスト
  String getMemorizeTimeString(ItemTableInfo itemTableInfo, int gameLevel) {
    String ret = " ";

    //メッセージ文生成
    if (isAllCorrect(itemTableInfo.tableItems, itemTableInfo.answerItemNum)) {
      Duration? duration = itemTableInfo.memorizeTime;
      if (duration != null) {
        ret = "Time ${getFormattedTime(duration)}";
      }
    }

    return ret;
  }
}
