import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/image_path.dart';
import 'package:memory_game/model/item_table_info.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/state/app_info_state.dart';
import 'package:memory_game/services/admob.dart';
import 'package:memory_game/state/item_table_info_state.dart';
import 'package:memory_game/view/util/util.dart';
import 'package:memory_game/view/util/widget.dart';

class ResultView extends ConsumerStatefulWidget {
  const ResultView({super.key});

  @override
  ConsumerState<ResultView> createState() => _AnswerViewState();
}

class _AnswerViewState extends ConsumerState<ResultView> {
  @override
  Widget build(BuildContext context) {
    final itemTableInfo = ref.watch(itemTableInfoProvider);
    final gameLevel = ref.watch(gameLevelProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: DefColor.lightBeige,
        body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                //メッセージ
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: context.widthByRatio(0.9),
                    child: FittedBox(
                      child: Text(
                        getAboveMessageString(itemTableInfo, gameLevel),
                        style: const TextStyle(
                          color: DefColor.textBlack,
                        ),
                      ),
                    ),
                  ),
                ),
                //タイム
                SizedBox(
                  height: context.widthByRatio(0.08),
                  child: FittedBox(
                    child: Text(
                      getMemorizeTimeString(itemTableInfo, gameLevel),
                      style: const TextStyle(
                        fontSize: 25,
                        color: DefColor.textBlack,
                      ),
                    ),
                  ),
                ),
                //アイテムテーブル
                SizedBox(
                    width: getItemTableWidth(),
                    child: CorrectAnswerTable(
                        rowNum: itemTableInfo.rowNum,
                        tableItems: itemTableInfo.tableItems)),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Spacer(
                        flex: 1,
                      ),
                      //ホームボタン
                      MyTextButton(
                          onPressed: () {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          },
                          text: "Home"),
                      const Spacer(
                        flex: 1,
                      ),
                      isAllCorrect(itemTableInfo.tableItems,
                              itemTableInfo.answerItemNum)
                          ? SizedBox(
                              height: context.widthByRatio(1 / 10),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(children: [
                                  //コメント
                                  Image.asset(
                                    defLevelImages[gameLevel],
                                  ),
                                  Container(
                                      alignment: Alignment.centerRight,
                                      child: const FittedBox(
                                        child: Text(
                                          "◀",
                                          style: TextStyle(
                                              color: DefColor.darkBeige),
                                        ),
                                      )),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: DefColor.darkBeige,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: FittedBox(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .resultComment,
                                        style: const TextStyle(
                                          color: DefColor.textBlack,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                            )
                          : Container(),
                      const Spacer(
                        flex: 1,
                      ),
                      //バナー
                      AdmobBanner(
                        adUnitId: AdMobService().getBannerAdUnitId(),
                        adSize: AdmobBannerSize.BANNER,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  //タイムのテキスト
  String getMemorizeTimeString(ItemTableInfo itemTableInfo, int gameLevel) {
    String ret = " ";

    //メッセージ文生成
    if (isAllCorrect(itemTableInfo.tableItems, itemTableInfo.answerItemNum)) {
      Duration? duration = itemTableInfo.memorizeTime;
      if (duration != null) {
        ret = "Time ${getFormattedTime(duration)}}";
      }
    }

    return ret;
  }

  //アイテムテーブルの幅
  double getItemTableWidth() {
    double ret = context.widthByRatio(0.9) *
        (context.sizeHeight / context.sizeWidth) /
        1.67;

    if (ret > context.widthByRatio(0.8)) {
      ret = context.widthByRatio(0.8);
    }

    return ret;
  }
}
