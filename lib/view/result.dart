import 'package:flutter/material.dart';
import 'package:memory_game/l10n/app_localizations.dart';
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

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: DefColor.lightBeige,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final commentHeight = isAllCorrect(
                      itemTableInfo.tableItems, itemTableInfo.answerItemNum)
                  ? 52.0
                  : 0.0;
              final tableSize = context.tableSizeFor(
                constraints,
                topReserve: 72 + context.sectionGap,
                bottomReserve: context.buttonHeight +
                    commentHeight +
                    50 +
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
                        //メッセージ
                        Text(
                          getAboveMessageString(itemTableInfo, gameLevel),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: DefColor.textBlack,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        //タイム
                        Text(
                          getMemorizeTimeString(itemTableInfo, gameLevel),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            color: DefColor.textBlack,
                          ),
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
                                  onPressed: () {
                                    Navigator.popUntil(
                                        context, (route) => route.isFirst);
                                  },
                                  text: "Home"),
                              SizedBox(height: context.sectionGap),
                              isAllCorrect(itemTableInfo.tableItems,
                                      itemTableInfo.answerItemNum)
                                  ? SizedBox(
                                      height: commentHeight,
                                      child: Row(children: [
                                        //コメント
                                        Image.asset(
                                          defLevelImages[gameLevel],
                                        ),
                                        const Text(
                                          "◀",
                                          style: TextStyle(
                                            color: DefColor.darkBeige,
                                            fontSize: 22,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: DefColor.darkBeige,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .resultComment,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: DefColor.textBlack,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    )
                                  : Container(),
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
        ret = "Time ${getFormattedTime(duration)}";
      }
    }

    return ret;
  }
}
