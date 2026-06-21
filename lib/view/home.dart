import 'package:flutter/material.dart';
import 'package:memory_game/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/image_path.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/state/app_info_state.dart';
import 'package:memory_game/services/admob.dart';
import 'package:memory_game/state/item_table_info_state.dart';
import 'package:memory_game/state/level_infos_state.dart';
import 'package:memory_game/view/memorize.dart';
import 'package:memory_game/view/util/util.dart';
import 'package:memory_game/view/util/widget.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameLevel = ref.watch(gameLevelProvider);
    final levelInfos = ref.watch(levelInfosProvider);

    //表示するベストタイムを設定
    List<Widget> memorizeTimes = [];
    for (int i = 0; i < levelInfos[gameLevel].recordInfos.length; i++) {
      memorizeTimes.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              " ${i + 1}.   ${getFormattedTime(levelInfos[gameLevel].recordInfos[i].memorizeTime)}  (${DateFormat('yyyy-MM-dd').format(levelInfos[gameLevel].recordInfos[i].recordedDate)})",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DefColor.textBlack,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
              padding: const EdgeInsets.all(10.0),
              height: 5.0,
              decoration: BoxDecoration(
                color: DefColor.orangeSoft,
                borderRadius: BorderRadius.circular(10),
              ))
        ],
      ));
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: DefColor.lightBeige,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fixedHeight = 96 +
                  28 +
                  context.levelSelectHeight +
                  context.buttonHeight +
                  50;
              final gaps = context.sectionGap * 6;
              final recordHeight = (constraints.maxHeight - fixedHeight - gaps)
                  .clamp(120.0, 260.0);

              return Stack(
                children: [
                  //ランク背景画像
                  if (getRank(levelInfos) != -1)
                    Align(
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: 0.3,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: context.contentWidth,
                            maxHeight: constraints.maxHeight * 0.58,
                          ),
                          child: Image.asset(
                            defLevelImages[getRank(levelInfos)],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
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
                            //タイトル
                            Text(
                              AppLocalizations.of(context)!.homeGameTitle,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: DefColor.darkBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 34,
                              ),
                            ),
                            SizedBox(height: context.sectionGap),
                            //ベストタイム
                            Text(
                              "Level ${gameLevel + 1} Best Time",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: DefColor.textBlack,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            //タイム
                            Container(
                              width: context.contentWidth,
                              height: recordHeight,
                              padding: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                color: DefColor.surface,
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
                                          style: const TextStyle(
                                            color: DefColor.textBlack,
                                            fontSize: 16,
                                            height: 1.4,
                                          ),
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
                            SizedBox(height: context.sectionGap),
                            //レベル選択ピッカー
                            LevelSelect(
                                level: gameLevel,
                                lockedLevel: getLockedLevel(levelInfos),
                                onPressed: (level) {
                                  ref.read(gameLevelProvider.notifier).state =
                                      level;
                                }),
                            SizedBox(height: context.sectionGap),
                            //スタートボタン
                            MyTextButton(
                              onPressed: levelInfos[gameLevel].isLocked
                                  ? null
                                  : () {
                                      final gameLevel =
                                          ref.read(gameLevelProvider);

                                      //テーブルを生成
                                      ref
                                          .read(itemTableInfoProvider.notifier)
                                          .createTableItems(gameLevel);

                                      //記憶画面へ遷移
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MemorizeView()),
                                      );
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
