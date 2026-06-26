import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:memory_game/l10n/app_localizations.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/num_constant.dart';
import 'package:memory_game/constant/text_style.dart';
import 'package:memory_game/model/item_table_info.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/view/util/pressable.dart';

typedef AnswerTablePressed = void Function(int index, int ansIndex);

// タイルの角丸（高齢者にもやわらかく見えるよう統一）。
const double _tileRadius = 12;

class GameTopBar extends StatelessWidget {
  final int level;
  final String? trailingText;
  // trailingText の前に添えるアイコン（タイムの時計など）。
  final IconData? trailingIcon;
  final VoidCallback? onHomePressed;

  const GameTopBar({
    super.key,
    required this.level,
    this.trailingText,
    this.trailingIcon,
    this.onHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DefColor.surface,
        border: Border(
          bottom: BorderSide(color: DefColor.darkBeige, width: 2),
        ),
      ),
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
                  // 端末幅やシステム文字サイズが大きい場合でも Row があふれない
                  // よう Flexible で包み、収まらなければ省略表示にする。
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.levelLabel(level + 1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.heading,
                    ),
                  ),
                  if (trailingText != null) ...[
                    const SizedBox(width: 14),
                    if (trailingIcon != null) ...[
                      Icon(trailingIcon, size: 22, color: DefColor.textBlack),
                      const SizedBox(width: 6),
                    ],
                    // タイムは左寄せにして左端を固定する。等幅数字を持たない
                    // フォントでも、数字が変わるたびに位置がブレないようにする。
                    Flexible(
                      child: Text(
                        trailingText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppText.topBarTrailing,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//テキストボタン（押すと凹む立体ボタン）
class MyTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color textColor;
  final Color backColor;
  final Color? edgeColor;
  final double widthRatio;
  final double heightRatio;
  final PressHaptic haptic;

  const MyTextButton(
      {required this.text,
      required this.onPressed,
      this.textColor = DefColor.textWhite,
      this.backColor = DefColor.orange,
      this.edgeColor,
      this.widthRatio = 0.5,
      this.heightRatio = 0.15,
      this.haptic = PressHaptic.medium,
      super.key});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final base = enabled ? backColor : DefColor.gray;
    final edge = enabled ? (edgeColor ?? darken(base)) : DefColor.grayDeep;

    return SizedBox(
      width: context.buttonWidth(widthRatio),
      height: context.buttonHeightFor(heightRatio),
      child: PressableButton(
        onPressed: onPressed,
        color: base,
        edgeColor: edge,
        haptic: haptic,
        depth: 6,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.button.copyWith(color: textColor),
        ),
      ),
    );
  }
}

//〇ボタン（押すと凹む立体ボタン）
class MyCircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onHoldChanged;
  final Color backColor;
  final double ratio;
  final PressHaptic haptic;
  const MyCircleButton(
      {required this.child,
      this.onPressed,
      this.onHoldChanged,
      this.backColor = DefColor.darkBlue,
      this.ratio = 1 / 5,
      this.haptic = PressHaptic.light,
      super.key});

  @override
  Widget build(BuildContext context) {
    final size = context.circleButtonSize * ratio / (1 / 5);
    const depth = 5.0;
    return SizedBox(
      width: size,
      height: size + depth,
      child: PressableButton(
        shape: BoxShape.circle,
        depth: depth,
        color: backColor,
        haptic: haptic,
        onPressed: onPressed,
        onHoldChanged: onHoldChanged,
        child: child,
      ),
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
        // 余白は HiddenTable と揃え、隠す前後で四角のサイズが変わらないようにする。
        widgets.add(AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            // 覚えている間になんとなくイラストに触れたくなるので、タップに
            // 触覚と凹みのエフェクトだけで反応する（操作音はプレイ画面では
            // 抑制済み）。ゲームの状態は変えない＝反応そのものが目的。
            child: PressableTile(
              borderRadius: BorderRadius.circular(_tileRadius),
              haptic: PressHaptic.selection,
              onPressed: () {},
              child: _TileSurface(child: TableIcon(icon: element.icon!)),
            ),
          ),
        ));
      } else {
        widgets.add(Container());
      }
    }

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
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
      //ビルド後の破棄でコールバックが発火した場合の防御(破棄済みrefへの書き込み回避)
      if (!mounted) {
        return;
      }
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
        final selected = i == widget.selectedIndex;
        widgets.add(AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              key: _answerItemKeys[ansIndex],
              child: PressableTile(
                borderRadius: BorderRadius.circular(_tileRadius),
                haptic: PressHaptic.selection,
                onPressed: () {
                  widget.onPressed(i, tmpAnsIndex);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: DefColor.orange,
                    borderRadius: BorderRadius.circular(_tileRadius),
                    border: selected
                        ? Border.all(color: DefColor.select, width: 5)
                        : null,
                  ),
                  child: widget.tableItems[i].answeredIcon != null
                      ? TableIcon(icon: widget.tableItems[i].answeredIcon!)
                      : const Center(
                          child: Text(
                            "?",
                            style: TextStyle(
                              color: DefColor.textWhite,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
            )));
        ansIndex++;
      } else if (widget.tableItems[i].isShowItem) {
        //回答対象のアイテムでない場合
        widgets.add(const AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: EdgeInsets.all(3.0),
            child: _TileSurface(),
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
        physics: const NeverScrollableScrollPhysics(),
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
        final isCorrect =
            widget.tableItems[i].icon == widget.tableItems[i].answeredIcon;
        final revealed = _pressedItemIndexies.contains(i);
        widgets.add(AspectRatio(
            aspectRatio: 1,
            child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: PressableTile(
                  borderRadius: BorderRadius.circular(_tileRadius),
                  haptic: PressHaptic.light,
                  onPressed: () {
                    if (revealed) {
                      _pressedItemIndexies.remove(i);
                    } else {
                      _pressedItemIndexies.add(i);
                    }
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: DefColor.orange,
                      borderRadius: BorderRadius.circular(_tileRadius),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        revealed
                            ? TableIcon(icon: widget.tableItems[i].icon!)
                            : widget.tableItems[i].answeredIcon != null
                                ? TableIcon(
                                    icon: widget.tableItems[i].answeredIcon!)
                                : Container(),
                        revealed
                            ? Container()
                            : isCorrect
                                //正解：緑のチェックマーク
                                ? const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: ExpandedIcon(
                                        icon: Icons.circle_outlined,
                                        color: DefColor.green),
                                  )
                                //不正解：赤のバツ
                                : const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: ExpandedIcon(
                                        icon: Icons.clear,
                                        color: DefColor.red)),
                      ],
                    ),
                  ),
                ))));
      } else if (widget.tableItems[i].isShowItem) {
        //回答対象のアイテムでない場合
        widgets.add(AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: _TileSurface(
                child: TableIcon(icon: widget.tableItems[i].icon!)),
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
        physics: const NeverScrollableScrollPhysics(),
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
        widgets.add(const AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: EdgeInsets.all(3.0),
            child: _TileSurface(),
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
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1,
        crossAxisCount: rowNum,
        children: widgets,
      ),
    );
  }
}

//テーブルのアイテムを載せる地（やわらかい角丸のタイル）
class _TileSurface extends StatelessWidget {
  final Widget? child;
  const _TileSurface({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DefColor.darkBeige,
        borderRadius: BorderRadius.circular(_tileRadius),
      ),
      child: child,
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
      child: ShadowedImage(icon),
    );
  }
}

//アイコン画像。背景色と同化しないよう、形に沿った柔らかい影を重ねる。
class ShadowedImage extends StatelessWidget {
  final String asset;
  const ShadowedImage(this.asset, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        //影：アイコンのシルエットをぼかして少し下にずらす。
        Transform.translate(
          offset: const Offset(0, 2),
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 1.8, sigmaY: 1.8),
            child: Image.asset(
              asset,
              color: const Color(0x66000000),
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
        Image.asset(asset),
      ],
    );
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
  // タップ起因の自動スクロール中は ListWheel の選択フィードバックを抑制し、
  // 操作音が二重に鳴るのを防ぐ。
  bool _suppressWheelFeedback = false;

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
      final locked = i >= widget.lockedLevel;
      final selected = _level == i;
      final Color tileColor = locked
          ? DefColor.gray
          : selected
              ? DefColor.orange
              : DefColor.lightBlue;
      final Color textColor = locked
          ? DefColor.textWhite
          : selected
              ? DefColor.textWhite
              : DefColor.darkBlueDeep;

      widgets.add(RotatedBox(
        quarterTurns: 1,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          child: PressableTile(
            borderRadius: BorderRadius.circular(_tileRadius),
            haptic: PressHaptic.selection,
            onPressed: () async {
              widget.onPressed(i);
              setState(() => _level = i);
              // タップ→自動スクロールの間は onSelectedItemChanged 側の
              // フィードバックを止める（タップ側で既に操作音を鳴らしている）。
              _suppressWheelFeedback = true;
              await _scrollController.animateToItem(i,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut);
              if (mounted) _suppressWheelFeedback = false;
            },
            child: Container(
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(_tileRadius),
              ),
              child: SizedBox(
                height: height - 12,
                child: Center(
                  child: Text(
                    "${i + 1}",
                    style: AppText.tileNumber.copyWith(color: textColor),
                  ),
                ),
              ),
            ),
          ),
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
                // タップ起因の自動スクロール中は二重に鳴らさない。
                // ドラッグ／フリックでの選択時のみ操作音＋触覚を出す。
                if (_suppressWheelFeedback) return;
                firePressFeedback(PressHaptic.selection);
                widget.onPressed(value);
                setState(() => _level = value);
              },
              offAxisFraction: -1,
              diameterRatio: 100,
              itemExtent: itemExtent,
              children: widgets,
            )));
  }
}

// しっぽ付きの吹き出し。本体（角丸の四角）としっぽ（三角）を
// 1つの塗りでつなげて描くことで、すき間なく自然な吹き出しになる。
class SpeechBubble extends StatelessWidget {
  final Widget child;
  final Color color;

  // しっぽが向く方向（話し手のいる側）。
  final TextDirection tailSide;

  // しっぽの大きさ。
  final double tailWidth;
  final double tailHeight;

  // 本体の角丸。
  final double radius;

  // 本体内側の余白。
  final EdgeInsets padding;

  const SpeechBubble({
    super.key,
    required this.child,
    this.color = DefColor.darkBeige,
    this.tailSide = TextDirection.ltr,
    this.tailWidth = 12,
    this.tailHeight = 18,
    this.radius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    // しっぽが左向き(ltr)なら左側に、右向き(rtl)なら右側に本体内側の余白を寄せる。
    final innerPadding = padding.add(EdgeInsets.only(
      left: tailSide == TextDirection.ltr ? tailWidth : 0,
      right: tailSide == TextDirection.rtl ? tailWidth : 0,
    ));

    return CustomPaint(
      painter: _SpeechBubblePainter(
        color: color,
        tailSide: tailSide,
        tailWidth: tailWidth,
        tailHeight: tailHeight,
        radius: radius,
      ),
      child: Padding(
        padding: innerPadding,
        child: child,
      ),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  final Color color;
  final TextDirection tailSide;
  final double tailWidth;
  final double tailHeight;
  final double radius;

  const _SpeechBubblePainter({
    required this.color,
    required this.tailSide,
    required this.tailWidth,
    required this.tailHeight,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final isLeft = tailSide == TextDirection.ltr;

    // しっぽぶんを除いた本体の四角。
    final bodyRect = Rect.fromLTRB(
      isLeft ? tailWidth : 0,
      0,
      isLeft ? size.width : size.width - tailWidth,
      size.height,
    );

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(bodyRect, Radius.circular(radius)));

    // しっぽ（縦中央から本体の縁に向かう三角）。本体と同じ塗りで重ねる。
    final cy = size.height / 2;
    final tail = Path();
    if (isLeft) {
      tail
        ..moveTo(tailWidth, cy - tailHeight / 2)
        ..lineTo(0, cy)
        ..lineTo(tailWidth, cy + tailHeight / 2)
        ..close();
    } else {
      final edge = size.width - tailWidth;
      tail
        ..moveTo(edge, cy - tailHeight / 2)
        ..lineTo(size.width, cy)
        ..lineTo(edge, cy + tailHeight / 2)
        ..close();
    }

    canvas.drawPath(Path.combine(PathOperation.union, path, tail), paint);
  }

  @override
  bool shouldRepaint(_SpeechBubblePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.tailSide != tailSide ||
        oldDelegate.tailWidth != tailWidth ||
        oldDelegate.tailHeight != tailHeight ||
        oldDelegate.radius != radius;
  }
}

// ホームボタン（押すと凹む立体の丸ボタン）
class HomeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const HomeButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final size = context.homeButtonSize;
    const depth = 5.0;
    return SizedBox(
      width: size,
      height: size + depth,
      child: PressableButton(
        shape: BoxShape.circle,
        depth: depth,
        color: DefColor.darkBlue,
        haptic: PressHaptic.medium,
        onPressed: () {
          final func = onPressed ?? () {};
          func();
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        child: const Icon(
          Icons.home,
          color: DefColor.textWhite,
          size: 26,
        ),
      ),
    );
  }
}
