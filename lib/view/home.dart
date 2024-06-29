import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/image_path.dart';
import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/model/level_infos.dart';
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
            child: FittedBox(
              child: Text(
                " ${i + 1}.   ${getFormattedTime(levelInfos[gameLevel].recordInfos[i].memorizeTime)}  (${DateFormat('yyyy-MM-dd').format(levelInfos[gameLevel].recordInfos[i].recordedDate)})",
                style: const TextStyle(
                  color: DefColor.textBlack,
                ),
              ),
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

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: DefColor.lightBeige,
        body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            child: Stack(
              children: [
                //ランク背景画像
                getRank(levelInfos) == -1
                    ? Container()
                    : SizedBox(
                        height: context.heightByRatio(2 / 3),
                        child: Align(
                          alignment: Alignment.center,
                          child: Opacity(
                            opacity: 0.3,
                            child: Image.asset(
                              defLevelImages[getRank(levelInfos)],
                            ),
                          ),
                        ),
                      ),
                Column(
                  children: [
                    const Spacer(flex: 2),
                    //タイトル
                    Container(
                      width: context.widthByRatio(0.8),
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                        child: Text(
                          AppLocalizations.of(context)!.homeGameTitle,
                          style: const TextStyle(
                              color: DefColor.darkBlue,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Spacer(),
                    //ベストタイム
                    SizedBox(
                      width: context.widthByRatio(0.5),
                      child: FittedBox(
                        child: Text(
                          "Level ${gameLevel + 1} Best Time",
                          style: const TextStyle(
                            color: DefColor.textBlack,
                          ),
                        ),
                      ),
                    ),
                    //タイム
                    Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: DefColor.darkBeige, width: 5.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: memorizeTimes.isEmpty
                          //記録がなければメッセージ表示
                          ? SizedBox(
                              height: context.heightByRatio(0.3),
                              width: context.widthByRatio(0.7),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.all(0.0),
                                  child: FittedBox(
                                    child: levelInfos[gameLevel].isLocked
                                        //レベルがロックされている場合のメッセージ
                                        ? Text(
                                            AppLocalizations.of(context)!
                                                .homeLockedLevel,
                                            style: const TextStyle(
                                              color: DefColor.textBlack,
                                            ),
                                          )
                                        //記録がない場合のメッセージ
                                        : Text(
                                            AppLocalizations.of(context)!
                                                .homeNoRecords,
                                            style: const TextStyle(
                                              color: DefColor.textBlack,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            )
                          //記録がある場合は記録を表示
                          : Scrollbar(
                              thumbVisibility: true,
                              child: Container(
                                  padding: const EdgeInsets.all(7.0),
                                  height: context.heightByRatio(0.3),
                                  width: context.widthByRatio(0.7),
                                  child: ListView(children: memorizeTimes)),
                            ),
                    ),
                    const Spacer(),
                    //レベル選択ピッカー
                    LevelSelect(
                        level: gameLevel,
                        lockedLevel: _getLockedLevel(levelInfos),
                        onPressed: (level) {
                          ref.read(gameLevelProvider.notifier).state = level;
                        }),
                    const Spacer(
                      flex: 1,
                    ),
                    SizedBox(
                      height: context.widthByRatio(1 / 4),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child:
                                //スタートボタン
                                MyTextButton(
                              backColor: levelInfos[gameLevel].isLocked
                                  ? DefColor.gray
                                  : DefColor.orange,
                              onPressed: levelInfos[gameLevel].isLocked
                                  ? () {}
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
                          ),
                        ],
                      ),
                    ),
                    const Spacer(
                      flex: 3,
                    ),
                    //バナー
                    AdmobBanner(
                      adUnitId: AdMobService().getBannerAdUnitId(),
                      adSize: AdmobBannerSize.BANNER,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ロック中のレベルを取得する関数
int _getLockedLevel(List<LevelInfo> levelInfos) {
  for (int i = 0; i < levelInfos.length; i++) {
    if (levelInfos[i].isLocked == true) {
      return i;
    }
  }
  // ロック中のレベルがない場合、最大レベル+1を返す
  return DefNum.maxLevel + 1;
}
