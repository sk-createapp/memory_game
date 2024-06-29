import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/model/item_table_info.dart';
import 'package:memory_game/model/level_infos.dart';
import 'package:memory_game/state/app_info_state.dart';
import 'package:memory_game/state/game_info_state.dart';
import 'package:memory_game/state/item_table_info_state.dart';
import 'package:memory_game/state/level_infos_state.dart';
import 'package:memory_game/view/result.dart';
import 'package:memory_game/view/util/util.dart';
import 'package:memory_game/view/util/widget.dart';

const _modalInitSize = 0.13;
const _modalMaxSize = 0.9;
const _modalMinSize = 0.12;

class AnswerView extends ConsumerStatefulWidget {
  final List<String> iconChoices;
  const AnswerView({required this.iconChoices, super.key});

  @override
  ConsumerState<AnswerView> createState() => _AnswerViewState();
}

class _AnswerViewState extends ConsumerState<AnswerView> {
  int? _selectedAnswerItemIndex;
  int? _selectedChoiceIndex;
  final _draggableController = DraggableScrollableController();
  final List<int> _answerTableItemIndexies = [];

  @override
  Widget build(BuildContext context) {
    final itemTableInfo = ref.watch(itemTableInfoProvider);
    final answerItemHeights = ref.watch(answerItemHeightsProvider);
    final gameLevel = ref.watch(gameLevelProvider);

    //回答アイテムに関するクラス内変数の設定
    setAnswerItemIndex(itemTableInfo);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: DefColor.lightBeige,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    ColoredBox(
                      color: DefColor.darkBeige,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // ホームボタン
                            const HomeButton(),
                            SizedBox(
                              width: context.widthByRatio(0.05),
                            ),
                            //レベル
                            SizedBox(
                              height: context.widthByRatio(1 / 8),
                              child: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Text("Level ${gameLevel + 1}",
                                    style: const TextStyle(
                                      fontFeatures: [
                                        FontFeature.tabularFigures()
                                      ],
                                      color: DefColor.textBlack,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //メッセージ
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8.0, left: 24, right: 24),
                      child: SizedBox(
                        height: context.widthByRatio(0.07),
                        child: FittedBox(
                          alignment: Alignment.topLeft,
                          child: Text(
                            AppLocalizations.of(context)!.answerGuide,
                            style: const TextStyle(
                              color: DefColor.textBlack,
                            ),
                          ),
                        ),
                      ),
                    ),
                    //アイテムテーブル
                    SizedBox(
                        width: itemTableWidth(),
                        child: answerTable(itemTableInfo)),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Spacer(
                            flex: 1,
                          ),
                          //完了ボタン
                          MyTextButton(
                              onPressed: () {
                                final itemTableInfo =
                                    ref.read(itemTableInfoProvider);
                                if (_isCompletedAnswer(itemTableInfo)) {
                                  if (isAllCorrect(itemTableInfo.tableItems,
                                          DefNum.answerNum) &&
                                      itemTableInfo.memorizeTime != null) {
                                    //全問正解なら記録更新する
                                    int gameLevel = ref.read(gameLevelProvider);
                                    ref
                                        .read(levelInfosProvider.notifier)
                                        .addRecord(
                                            gameLevel,
                                            RecordInfo(
                                                memorizeTime:
                                                    itemTableInfo.memorizeTime!,
                                                recordedDate: DateTime.now()));

                                    //ゲームインフォのクリア回数をインクリメントしてSP/Provider更新
                                    ref
                                        .read(gameInfoProvider.notifier)
                                        .incrementClearNum();
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ResultView()),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      //確認画面
                                      return const GiveUpDialog();
                                    },
                                  );
                                }
                              },
                              text: AppLocalizations.of(context)!.cmnOk),
                          const Spacer(
                            flex: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //選択肢テーブル
              selectionTable(itemTableInfo, answerItemHeights),
            ],
          ),
        ),
      ),
    );
  }

  //回答アイテムに関するクラス内変数の設定
  void setAnswerItemIndex(ItemTableInfo itemTableInfo) {
    for (int i = 0; i < itemTableInfo.tableItems.length; i++) {
      if (itemTableInfo.tableItems[i].isAnswerItem) {
        _answerTableItemIndexies.add(i);
        _selectedAnswerItemIndex ??= 0;
      }
    }
  }

  //アイテムテーブルの幅
  double itemTableWidth() {
    //アイテムボックスの幅設定
    double ret = context.widthByRatio(0.9) *
        (context.sizeHeight / context.sizeWidth) /
        1.67;

    if (ret > context.widthByRatio(0.9)) {
      ret = context.widthByRatio(0.9);
    }
    return ret;
  }

  //アイテムテーブル
  Widget answerTable(ItemTableInfo itemTableInfo) {
    return AnswerTable(
      rowNum: itemTableInfo.rowNum,
      tableItems: itemTableInfo.tableItems,
      selectedIndex: _selectedAnswerItemIndex == null
          ? null
          : _answerTableItemIndexies[_selectedAnswerItemIndex!],
      onPressed: (index, ansIndex) {
        setState(() {
          _selectedAnswerItemIndex = _answerTableItemIndexies.indexOf(index);
          if (itemTableInfo.tableItems[index].answeredIcon == null) {
            _selectedChoiceIndex = null;
          } else {
            _selectedChoiceIndex = widget.iconChoices
                .indexOf(itemTableInfo.tableItems[index].answeredIcon!);
          }

          //選択肢モーダルを開く
          _draggableController.animateTo(_modalMaxSize,
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear);
        });
      },
      getItemHeights: (itemHeights) {
        ref.read(answerItemHeightsProvider.notifier).state =
            List.of(itemHeights);
      },
    );
  }

  //選択肢テーブル
  Widget selectionTable(
      ItemTableInfo itemTableInfo, List<double> answerItemHeights) {
    //選択肢生成
    List<Widget> choices = [];
    for (int i = 0; i < 36; i++) {
      choices.add(Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), //角の丸み
          border: Border.all(
            width: 5,
            color: (_selectedChoiceIndex == i)
                ? DefColor.orange
                : DefColor.none, //枠線の色
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: GestureDetector(
            //シングルタップ
            onTap: () {
              _selectedChoiceIndex = i;
              final selectedAnswerItemIndex = _selectedAnswerItemIndex;
              if (selectedAnswerItemIndex != null) {
                //アイテムテーブル更新
                ref.read(itemTableInfoProvider.notifier).answerItem(
                    _answerTableItemIndexies[selectedAnswerItemIndex],
                    widget.iconChoices[i]);
                //選択肢を閉じる
                _draggableController.animateTo(_modalMinSize,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.linear);
                setState(() {});
              }
            },
            //ダブルタップ
            onDoubleTap: () {
              _selectedChoiceIndex = i;
              if (_selectedAnswerItemIndex != null) {
                //アイテムテーブル更新
                ref.read(itemTableInfoProvider.notifier).answerItem(
                    _answerTableItemIndexies[_selectedAnswerItemIndex!],
                    widget.iconChoices[i]);
                //ダブルタップした場合はフォーカスを次の回答アイテムに移動する
                _selectedAnswerItemIndex = (_selectedAnswerItemIndex! + 1) % 3;
                _selectedChoiceIndex = itemTableInfo
                            .tableItems[_answerTableItemIndexies[
                                _selectedAnswerItemIndex!]]
                            .answeredIcon ==
                        null
                    ? null
                    : widget.iconChoices.indexOf(itemTableInfo
                        .tableItems[
                            _answerTableItemIndexies[_selectedAnswerItemIndex!]]
                        .answeredIcon!);

                //選択肢モーダルを回答アイテムの高さまで移動
                if (_selectedAnswerItemIndex! != 0) {
                  _draggableController.animateTo(
                      (context.sizeHeight -
                              answerItemHeights[_selectedAnswerItemIndex!]) /
                          context.sizeHeight,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.linear);
                } else {
                  _draggableController.animateTo(_modalInitSize,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.linear);
                }
                setState(() {});
              }
            },
            child: Image.asset(
              widget.iconChoices[i],
            ),
          ),
        ),
      ));
    }

    return DraggableScrollableSheet(
      initialChildSize: _modalInitSize,
      minChildSize: _modalMinSize,
      maxChildSize: _modalMaxSize,
      controller: _draggableController,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
            decoration: const BoxDecoration(
              color: DefColor.lightBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: context.heightByRatio(0.1),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_draggableController.size > _modalInitSize) {
                            _draggableController.animateTo(_modalInitSize,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.linear);
                          } else {
                            _draggableController.animateTo(_modalMaxSize,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.linear);
                          }
                          setState(() {});
                        },
                        child: Container(
                          width: context.sizeWidth,
                          color: DefColor.none,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 3,
                                    color: DefColor.darkBeige,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: context.heightByRatio(1 / 10),
                                      child: FittedBox(
                                        fit: BoxFit.fitHeight,
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .answerChoice,
                                          style: const TextStyle(
                                            color: DefColor.textBlack,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    childAspectRatio: 1,
                    crossAxisCount: 6,
                    children: choices,
                  ),
                ),
              ],
            ));
      },
    );
  }
}

//未回答時の確認画面
class GiveUpDialog extends StatelessWidget {
  const GiveUpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DefColor.darkBeige,
      content: SizedBox(
        width: context.widthByRatio(0.8),
        height: context.widthByRatio(0.6),
        child: Column(
          children: [
            const Spacer(),
            SizedBox(
              height: context.widthByRatio(1 / 10),
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(
                  AppLocalizations.of(context)!.answerConfirm,
                  style: const TextStyle(
                    color: DefColor.textBlack,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Spacer(),
                MyTextButton(
                  text: AppLocalizations.of(context)!.cmnNo,
                  backColor: DefColor.darkBlue,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  widthRatio: 0.3,
                ),
                const Spacer(),
                MyTextButton(
                  text: AppLocalizations.of(context)!.cmnYes,
                  backColor: DefColor.darkBlue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ResultView()),
                    );
                  },
                  widthRatio: 0.3,
                ),
                const Spacer(
                  flex: 2,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

bool _isCompletedAnswer(ItemTableInfo itemTableInfo) {
  int answerdNum = itemTableInfo.tableItems.where((element) {
    return element.answeredIcon != null;
  }).length;

  return answerdNum == itemTableInfo.answerItemNum;
}
