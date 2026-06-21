import 'package:flutter/material.dart';
import 'package:memory_game/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/constant/text_style.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/model/item_table_info.dart';
import 'package:memory_game/model/level_infos.dart';
import 'package:memory_game/state/app_info_state.dart';
import 'package:memory_game/state/game_info_state.dart';
import 'package:memory_game/state/item_table_info_state.dart';
import 'package:memory_game/state/level_infos_state.dart';
import 'package:memory_game/view/result.dart';
import 'package:memory_game/view/util/pressable.dart';
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

  @override
  Widget build(BuildContext context) {
    final itemTableInfo = ref.watch(itemTableInfoProvider);
    final answerItemHeights = ref.watch(answerItemHeightsProvider);
    final gameLevel = ref.watch(gameLevelProvider);

    final answerTableItemIndexes = itemTableInfo.answerItemIndexes;
    _selectedAnswerItemIndex ??= answerTableItemIndexes.isEmpty ? null : 0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: DefColor.lightBeige,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sheetPeekHeight = constraints.maxHeight * _modalMinSize;
              final tableSize = context.tableSizeFor(
                constraints,
                topReserve: context.topBarHeight +
                    context.guideHeight +
                    context.sectionGap * 2,
                bottomReserve: context.buttonHeight +
                    sheetPeekHeight +
                    context.sectionGap * 3,
              );

              return Stack(
                children: [
                  Column(
                    children: [
                      GameTopBar(level: gameLevel),
                      //メッセージ
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.pagePadding,
                          context.sectionGap,
                          context.pagePadding,
                          0,
                        ),
                        child: SizedBox(
                          width: context.contentWidth,
                          height: context.guideHeight,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context)!.answerGuide,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.guide,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: context.sectionGap),
                      //アイテムテーブル
                      SizedBox.square(
                          dimension: tableSize,
                          child: answerTable(
                              itemTableInfo, answerTableItemIndexes)),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Spacer(),
                            //完了ボタン
                            MyTextButton(
                                onPressed: () {
                                  final itemTableInfo =
                                      ref.read(itemTableInfoProvider);
                                  if (isCompletedAnswer(itemTableInfo)) {
                                    bool isNewRecord = false;
                                    if (isAllCorrect(itemTableInfo.tableItems,
                                            DefNum.answerNum) &&
                                        itemTableInfo.memorizeTime != null) {
                                      //全問正解なら記録更新する
                                      int gameLevel =
                                          ref.read(gameLevelProvider);

                                      //追加前の自己ベストと比べて新記録か判定する
                                      final existingRecords = ref
                                          .read(levelInfosProvider)[gameLevel]
                                          .recordInfos;
                                      final bestTime = existingRecords.isEmpty
                                          ? null
                                          : existingRecords
                                              .map((e) => e.memorizeTime)
                                              .reduce((a, b) => a < b ? a : b);
                                      isNewRecord = bestTime == null ||
                                          itemTableInfo.memorizeTime! <
                                              bestTime;

                                      ref
                                          .read(levelInfosProvider.notifier)
                                          .addRecord(
                                              gameLevel,
                                              RecordInfo(
                                                  memorizeTime: itemTableInfo
                                                      .memorizeTime!,
                                                  recordedDate:
                                                      DateTime.now()));

                                      //ゲームインフォのクリア回数をインクリメントしてSP/Provider更新
                                      ref
                                          .read(gameInfoProvider.notifier)
                                          .incrementClearNum();
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ResultView(
                                              isNewRecord: isNewRecord)),
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
                            SizedBox(
                                height: sheetPeekHeight + context.sectionGap),
                          ],
                        ),
                      ),
                    ],
                  ),
                  //選択肢テーブル
                  selectionTable(
                      itemTableInfo, answerItemHeights, answerTableItemIndexes),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  //アイテムテーブル
  Widget answerTable(
      ItemTableInfo itemTableInfo, List<int> answerTableItemIndexes) {
    return AnswerTable(
      rowNum: itemTableInfo.rowNum,
      tableItems: itemTableInfo.tableItems,
      selectedIndex: _selectedAnswerItemIndex == null
          ? null
          : answerTableItemIndexes[_selectedAnswerItemIndex!],
      onPressed: (index, ansIndex) {
        setState(() {
          _selectedAnswerItemIndex = answerTableItemIndexes.indexOf(index);
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
    ItemTableInfo itemTableInfo,
    List<double> answerItemHeights,
    List<int> answerTableItemIndexes,
  ) {
    //選択肢生成
    List<Widget> choices = [];
    for (int i = 0; i < 36; i++) {
      final selected = _selectedChoiceIndex == i;
      choices.add(Padding(
        padding: const EdgeInsets.all(3.0),
        child: PressableTile(
          borderRadius: BorderRadius.circular(12),
          haptic: PressHaptic.selection,
          //シングルタップ
          onPressed: () {
            _selectedChoiceIndex = i;
            final selectedAnswerItemIndex = _selectedAnswerItemIndex;
            if (selectedAnswerItemIndex != null) {
              //アイテムテーブル更新
              ref.read(itemTableInfoProvider.notifier).answerItem(
                  answerTableItemIndexes[selectedAnswerItemIndex],
                  widget.iconChoices[i]);
              //選択肢を閉じる
              _draggableController.animateTo(_modalMinSize,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.linear);
              setState(() {});
            }
          },
          //ダブルタップ
          onDoublePressed: () {
            _selectedChoiceIndex = i;
            if (_selectedAnswerItemIndex != null) {
              //アイテムテーブル更新
              ref.read(itemTableInfoProvider.notifier).answerItem(
                  answerTableItemIndexes[_selectedAnswerItemIndex!],
                  widget.iconChoices[i]);
              //ダブルタップした場合はフォーカスを次の回答アイテムに移動する
              _selectedAnswerItemIndex = (_selectedAnswerItemIndex! + 1) %
                  answerTableItemIndexes.length;
              _selectedChoiceIndex = itemTableInfo
                          .tableItems[
                              answerTableItemIndexes[_selectedAnswerItemIndex!]]
                          .answeredIcon ==
                      null
                  ? null
                  : widget.iconChoices.indexOf(itemTableInfo
                      .tableItems[
                          answerTableItemIndexes[_selectedAnswerItemIndex!]]
                      .answeredIcon!);

              //選択肢モーダルを回答アイテムの高さまで移動
              if (_selectedAnswerItemIndex! != 0 &&
                  _selectedAnswerItemIndex! < answerItemHeights.length) {
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
          child: Container(
            decoration: BoxDecoration(
              color: selected ? DefColor.orangeSoft : DefColor.darkBeige,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                width: 4,
                color: selected ? DefColor.select : DefColor.darkBeige,
              ),
            ),
            child: TableIcon(icon: widget.iconChoices[i]),
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
            child: CustomScrollView(
              // ヘッダーと選択肢グリッドを1つのスクロールにまとめることで、
              // 選択肢の上など、どのエリアをドラッグしても
              //（スクロールが先頭まで来ていれば）シートを閉じられるようにする。
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
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
                    child: SizedBox(
                      width: double.infinity,
                      height: context.isCompactWidth ? 64 : 72,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //ドラッグできることを示すつまみ。
                              Container(
                                width: 56,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: DefColor.darkBeige,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  AppLocalizations.of(context)!.answerChoice,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.subheading,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                  sliver: SliverGrid.count(
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
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.pagePadding,
        vertical: 24,
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      content: SizedBox(
        width: context.contentWidth,
        height: (context.contentWidth * 0.62).clamp(180.0, 260.0),
        child: Column(
          children: [
            const Spacer(),
            Text(
              AppLocalizations.of(context)!.answerConfirm,
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppText.subheading,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: MyTextButton(
                    text: AppLocalizations.of(context)!.cmnNo,
                    backColor: DefColor.darkBlue,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: context.sectionGap * 1.5),
                Expanded(
                  child: MyTextButton(
                    text: AppLocalizations.of(context)!.cmnYes,
                    backColor: DefColor.darkBlue,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ResultView()),
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
