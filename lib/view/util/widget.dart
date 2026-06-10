import 'package:flutter/material.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/model/item_table_info.dart';
import 'package:memory_game/view/util/extension.dart';

typedef AnswerTablePressed = void Function(int index, int ansIndex);

class GameTopBar extends StatelessWidget {
  final int level;
  final String? trailingText;
  final VoidCallback? onHomePressed;

  const GameTopBar({
    super.key,
    required this.level,
    this.trailingText,
    this.onHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DefColor.darkBeige,
      child: SizedBox(
        height: context.topBarHeight,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
              child: Row(
                children: [
                  HomeButton(onPressed: onHomePressed),
                  SizedBox(width: context.sectionGap),
                  Text(
                    "Level ${level + 1}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()],
                      color: DefColor.textBlack,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (trailingText != null)
                    Expanded(
                      child: Text(
                        trailingText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFeatures: [FontFeature.tabularFigures()],
                          color: DefColor.textBlack,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//テキストボタン
class MyTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color textColor;
  final Color backColor;
  final double widthRatio;
  final double heightRatio;

  const MyTextButton(
      {required this.text,
      required this.onPressed,
      this.textColor = DefColor.textWhite,
      this.backColor = DefColor.orange,
      this.widthRatio = 0.5,
      this.heightRatio = 0.15,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.buttonWidth(widthRatio),
      height: context.buttonHeightFor(heightRatio),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(backColor),
          splashFactory: NoSplash.splashFactory,
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

//〇ボタン
class MyCircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color backColor;
  final double ratio;
  const MyCircleButton(
      {required this.child,
      required this.onPressed,
      this.backColor = DefColor.darkBlue,
      this.ratio = 1 / 5,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        fixedSize: Size.square(context.circleButtonSize * ratio / (1 / 5)),
        backgroundColor: backColor,
        splashFactory: NoSplash.splashFactory,
        shape: const CircleBorder(),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

//記憶用テーブル
class MemorizeTable extends StatelessWidget {
  final int rowNum;
  final List<TableItem> tableItems;
  const MemorizeTable({
    super.key,
    required this.rowNum,
    required this.tableItems,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    for (var element in tableItems) {
      if (element.icon != null) {
        widgets.add(TableIcon(icon: element.icon!));
      } else {
        widgets.add(Container());
      }
    }

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.count(
        childAspectRatio: 1,
        crossAxisCount: rowNum,
        children: widgets,
      ),
    );
  }
}

class AnswerTable extends StatefulWidget {
  final int rowNum;
  final List<TableItem> tableItems;
  final int? selectedIndex;
  final AnswerTablePressed onPressed;
  final ValueChanged<List<double>>? getItemHeights;

  const AnswerTable({
    super.key,
    required this.rowNum,
    required this.tableItems,
    this.selectedIndex,
    required this.onPressed,
    this.getItemHeights,
  });

  @override
  State<AnswerTable> createState() => _AnswerTableState();
}

class _AnswerTableState extends State<AnswerTable> {
  late List<GlobalKey> _answerItemKeys;

  @override
  void initState() {
    super.initState();
    _answerItemKeys = _createAnswerItemKeys();
  }

  @override
  void didUpdateWidget(covariant AnswerTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    final answerItemNum =
        widget.tableItems.where((item) => item.isAnswerItem).length;
    if (_answerItemKeys.length != answerItemNum) {
      _answerItemKeys = _createAnswerItemKeys();
    }
  }

  List<GlobalKey> _createAnswerItemKeys() {
    final answerItemNum =
        widget.tableItems.where((item) => item.isAnswerItem).length;
    return [for (int i = 0; i < answerItemNum; i++) GlobalKey()];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    int ansIndex = 0;

    //アイテムの高さを取得
    WidgetsBinding.instance.addPostFrameCallback((cb) {
      final func = widget.getItemHeights;
      if (func == null) {
        return;
      }
      List<double> results = [];

      for (var element in _answerItemKeys) {
        if (element.currentContext == null) {
          continue;
        }
        final box = element.currentContext!.findRenderObject() as RenderBox;
        results.add(box.localToGlobal(Offset.zero).dy + box.size.height);
      }

      func(results);
    });

    //アイテムリストを生成
    for (int i = 0; i < widget.tableItems.length; i++) {
      int tmpAnsIndex = ansIndex;
      if (widget.tableItems[i].isAnswerItem) {
        //回答対象のアイテムの場合
        widgets.add(AspectRatio(
            aspectRatio: 1,
            child: Padding(
                padding: const EdgeInsets.all(2.0),
                key: _answerItemKeys[ansIndex],
                child: ElevatedButton(
                  onPressed: () {
                    widget.onPressed(i, tmpAnsIndex);
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      surfaceTintColor: DefColor.none,
                      splashFactory: NoSplash.splashFactory,
                      backgroundColor: DefColor.orange,
                      side: i == widget.selectedIndex
                          ? const BorderSide(
                              color: DefColor.lightBlue, width: 5)
                          : null,
                      shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.circular(0)) //こちらを適用
                      ),
                  child: widget.tableItems[i].answeredIcon != null
                      ? TableIcon(
                          icon: widget.tableItems[i].answeredIcon!,
                        )
                      : SizedBox(
                          child: const Center(
                            child: Text(
                              "?",
                              style: TextStyle(
                                color: DefColor.textWhite,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ))));
        ansIndex++;
      } else if (widget.tableItems[i].isShowItem) {
        //回答対象のアイテムでない場合
        widgets.add(AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              color: DefColor.darkBeige,
              child: const SizedBox(
                width: 10,
                height: 10,
              ),
            ),
          ),
        ));
      } else {
        //アイテム表示でない場合
        widgets.add(Container());
      }
    }

    ansIndex = 0;

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.count(
        childAspectRatio: 1,
        crossAxisCount: widget.rowNum,
        children: widgets,
      ),
    );
  }
}

//正解テーブル
class CorrectAnswerTable extends StatefulWidget {
  final int rowNum;
  final List<TableItem> tableItems;
  const CorrectAnswerTable({
    super.key,
    required this.rowNum,
    required this.tableItems,
  });

  @override
  State<CorrectAnswerTable> createState() => _CorrectAnswerTableState();
}

class _CorrectAnswerTableState extends State<CorrectAnswerTable> {
  final List<int> _pressedItemIndexies = [];

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    for (int i = 0; i < widget.tableItems.length; i++) {
      if (widget.tableItems[i].isAnswerItem) {
        //回答対象のアイテムの場合
        widgets.add(AspectRatio(
            aspectRatio: 1,
            child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_pressedItemIndexies.contains(i)) {
                      _pressedItemIndexies.remove(i);
                    } else {
                      _pressedItemIndexies.add(i);
                    }
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      surfaceTintColor: DefColor.none,
                      splashFactory: NoSplash.splashFactory,
                      backgroundColor: DefColor.orange,
                      shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.circular(0))),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      _pressedItemIndexies.contains(i)
                          ? TableIcon(icon: widget.tableItems[i].icon!)
                          : widget.tableItems[i].answeredIcon != null
                              ? TableIcon(
                                  icon: widget.tableItems[i].answeredIcon!)
                              : Container(),
                      _pressedItemIndexies.contains(i)
                          ? Container()
                          : widget.tableItems[i].icon ==
                                  widget.tableItems[i].answeredIcon
                              ? Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: DefColor.none,
                                      border: Border.all(
                                          color: DefColor.red, width: 5),
                                    ),
                                  ),
                                )
                              : const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: ExpandedIcon(
                                      icon: Icons.clear, color: DefColor.red)),
                    ],
                  ),
                ))));
      } else if (widget.tableItems[i].isShowItem) {
        //回答対象のアイテムでない場合
        widgets.add(AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              color: DefColor.darkBeige,
              child: TableIcon(icon: widget.tableItems[i].icon!),
            ),
          ),
        ));
      } else {
        //アイテム表示でない場合
        widgets.add(Container());
      }
    }
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.count(
        childAspectRatio: 1,
        crossAxisCount: widget.rowNum,
        children: widgets,
      ),
    );
  }
}

//アイテム非表示状態のテーブル
class HiddenTable extends StatelessWidget {
  final int rowNum;
  final List<TableItem> tableItems;
  const HiddenTable({
    super.key,
    required this.rowNum,
    required this.tableItems,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    for (int i = 0; i < tableItems.length; i++) {
      if (tableItems[i].isShowItem) {
        //回答対象のアイテムでない場合
        widgets.add(AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              color: DefColor.darkBeige,
            ),
          ),
        ));
      } else {
        //アイテム表示でない場合
        widgets.add(Container());
      }
    }
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.count(
        childAspectRatio: 1,
        crossAxisCount: rowNum,
        children: widgets,
      ),
    );
  }
}

//テーブルに表示するアイコン
class TableIcon extends StatelessWidget {
  final String icon;
  const TableIcon({required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(4),
        child: Image.asset(
          icon,
        ));
  }
}

//expandやflexibleを親にできないwidgetでexpandのように使えるwidget
class ExpandedIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const ExpandedIcon({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
        return Container();
      }
      return SizedBox(
        child: Icon(
          icon,
          size: constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth
              : constraints.maxHeight,
          color: color,
        ),
      );
    });
  }
}

//レベルセレクトホイール
class LevelSelect extends StatefulWidget {
  final int level;
  final int lockedLevel;
  final ValueChanged<int> onPressed;
  const LevelSelect(
      {this.level = 0,
      required this.onPressed,
      required this.lockedLevel,
      super.key});

  @override
  State<LevelSelect> createState() => _LevelSelectState();
}

class _LevelSelectState extends State<LevelSelect> {
  int _level = 0;
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    _level = widget.level;
    _scrollController = FixedExtentScrollController(initialItem: widget.level);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = context.levelSelectHeight;
    final itemExtent = context.isCompactWidth ? 74.0 : 92.0;

    List<Widget> widgets = [];
    for (int i = 0; i < DefNum.maxLevel; i++) {
      widgets.add(RotatedBox(
        quarterTurns: 1,
        child: Container(
          padding: const EdgeInsets.all(3.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  surfaceTintColor: DefColor.none,
                  splashFactory: NoSplash.splashFactory,
                  backgroundColor: i >= widget.lockedLevel
                      ? DefColor.gray
                      : _level == i
                          ? DefColor.orange
                          : DefColor.lightBlue,
                  shape: RoundedRectangleBorder(
                      side: BorderSide.none,
                      borderRadius: BorderRadius.circular(0))),
              onPressed: () {
                widget.onPressed(i);
                _level = i;
                setState(() {});
                _scrollController.animateToItem(i,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.linear);
              },
              child: SizedBox(
                height: height - 12,
                child: Center(
                  child: Text(
                    "${i + 1}",
                    style: const TextStyle(
                      color: DefColor.textWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),
        ),
      ));
    }
    return SizedBox(
        width: context.contentWidth,
        height: height,
        child: RotatedBox(
            quarterTurns: -1,
            child: ListWheelScrollView(
              controller: _scrollController,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (value) {
                final int level = value;
                widget.onPressed(level);
                _level = level;
                setState(() {});
              },
              offAxisFraction: -1,
              diameterRatio: 100,
              itemExtent: itemExtent,
              children: widgets,
            )));
  }
}

// ホームボタン
class HomeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const HomeButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        fixedSize: Size.square(context.homeButtonSize),
        backgroundColor: DefColor.darkBlue,
        splashFactory: NoSplash.splashFactory,
        shape: const CircleBorder(),
      ),
      onPressed: () {
        final func = onPressed ?? () {};
        func();
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      icon: const Icon(
        Icons.home,
        color: DefColor.lightBeige,
      ),
    );
  }
}
