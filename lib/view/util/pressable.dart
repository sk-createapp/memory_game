import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory_game/constant/color_constant.dart';

/// ハプティクス（触覚フィードバック）の強さ。
enum PressHaptic { none, selection, light, medium, heavy }

/// 指定した強さの触覚フィードバックを再生する。
void fireHaptic(PressHaptic haptic) {
  switch (haptic) {
    case PressHaptic.none:
      break;
    case PressHaptic.selection:
      HapticFeedback.selectionClick();
    case PressHaptic.light:
      HapticFeedback.lightImpact();
    case PressHaptic.medium:
      HapticFeedback.mediumImpact();
    case PressHaptic.heavy:
      HapticFeedback.heavyImpact();
  }
}

/// 色を一段暗くする（立体ボタンの底面色を自動生成するためのユーティリティ）。
Color darken(Color color, [double amount = 0.16]) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

/// 押すと物理的に凹む立体ボタン。
///
/// 下端に一段濃い「土台」を描き、押下時に本体を土台へ沈めることで
/// 「押した」感触を視覚的に表現する。あわせて触覚フィードバックも再生する。
///
/// - タップ用途では [onPressed] を指定する。
/// - 押し続ける用途（記憶画面の「かくす」など）では [onHoldChanged] を指定する。
class PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onHoldChanged;
  final Color color;
  final Color? edgeColor;
  final double depth;
  final BorderRadius borderRadius;
  final BoxShape shape;
  final BoxBorder? border;
  final EdgeInsetsGeometry padding;
  final PressHaptic haptic;

  const PressableButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onHoldChanged,
    this.color = DefColor.orange,
    this.edgeColor,
    this.depth = 6,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.shape = BoxShape.rectangle,
    this.border,
    this.padding = EdgeInsets.zero,
    this.haptic = PressHaptic.medium,
  });

  bool get _enabled => onPressed != null || onHoldChanged != null;

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
    widget.onHoldChanged?.call(value);
  }

  void _handleTapDown(TapDownDetails _) {
    fireHaptic(widget.haptic);
    _setPressed(true);
  }

  void _handleTapUp(TapUpDetails _) {
    _setPressed(false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() => _setPressed(false);

  @override
  Widget build(BuildContext context) {
    final enabled = widget._enabled;
    final depth = widget.depth;
    final isCircle = widget.shape == BoxShape.circle;
    final edgeColor = widget.edgeColor ?? darken(widget.color);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? _handleTapDown : null,
      onTapUp: enabled ? _handleTapUp : null,
      onTapCancel: enabled ? _handleTapCancel : null,
      child: Padding(
        // 立体の底面と沈み込み分の高さを確保する。
        padding: EdgeInsets.only(bottom: depth),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _pressed ? depth : 0, 0),
          decoration: BoxDecoration(
            color: widget.color,
            shape: widget.shape,
            borderRadius: isCircle ? null : widget.borderRadius,
            border: widget.border,
            boxShadow: enabled && !_pressed
                ? [
                    BoxShadow(
                      color: edgeColor,
                      offset: Offset(0, depth),
                      blurRadius: 0,
                    ),
                  ]
                : const [],
          ),
          child: Padding(
            padding: widget.padding,
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// グリッド内のタイル用の押下ウィジェット。
///
/// 立体ボタンとは異なり、押すと少し縮みつつ薄く暗くなることで
/// 「凹む」感触を出す。密に並ぶタイルでも破綻しない軽量な表現。
class PressableTile extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onDoublePressed;
  final BorderRadius borderRadius;
  final PressHaptic haptic;

  const PressableTile({
    super.key,
    required this.child,
    required this.onPressed,
    this.onDoublePressed,
    this.borderRadius = BorderRadius.zero,
    this.haptic = PressHaptic.light,
  });

  @override
  State<PressableTile> createState() => _PressableTileState();
}

class _PressableTileState extends State<PressableTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled
          ? (_) {
              fireHaptic(widget.haptic);
              _setPressed(true);
            }
          : null,
      onTapUp: enabled
          ? (_) {
              _setPressed(false);
              widget.onPressed!.call();
            }
          : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onDoubleTap: widget.onDoublePressed == null
          ? null
          : () {
              fireHaptic(widget.haptic);
              widget.onDoublePressed!.call();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            widget.child,
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 90),
                  decoration: BoxDecoration(
                    color: _pressed ? DefColor.pressScrim : DefColor.none,
                    borderRadius: widget.borderRadius,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
