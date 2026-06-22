import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memory_game/constant/color_constant.dart';

/// クリア時の紙吹雪（コンフェッティ）を画面全体に降らせる演出。
///
/// 外部パッケージに依存せず、[AnimationController] と [CustomPainter] だけで
/// 完結させている。[intense] を true にすると枚数・色・継続時間が増え、
/// 新記録のときによりにぎやかな演出になる。
///
/// [durationSeconds] を指定すると継続時間を上書きできる。延ばした時間いっぱい
/// 紙吹雪が降り続けて見えるよう、降り始めの遅延と枚数も時間に合わせて増やす。
class ConfettiOverlay extends StatefulWidget {
  /// 新記録など、より派手にしたいときに true。
  final bool intense;

  /// 継続時間（秒）の上書き。null なら [intense] に応じた既定値。
  final double? durationSeconds;

  const ConfettiOverlay({
    super.key,
    this.intense = false,
    this.durationSeconds,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  // にぎやかに見える、彩度高めのお祝いカラー。
  static const List<Color> _palette = [
    DefColor.orange,
    DefColor.select,
    DefColor.darkBlue,
    DefColor.green,
    DefColor.red,
    DefColor.lightBlue,
    Color(0xFFE05A8A), // ピンク
    Color(0xFF7B6CE0), // バイオレット
    Color(0xFFF2C53D), // ゴールド
  ];

  // 重力（画面高さ/秒^2）。すべての紙片で共有する。
  static const double _gravity = 0.62;

  late final AnimationController _controller;
  late final List<_Confetto> _confetti;
  late final double _durationSeconds;

  @override
  void initState() {
    super.initState();

    // 乱数の種は固定し、毎回同じでも自然に見える範囲でばらつかせる。
    final rnd = math.Random(widget.intense ? 7 : 3);

    final int count;
    final double maxDelay;
    final double topSpread;
    final override = widget.durationSeconds;
    if (override != null) {
      // 表示時間が指定されたとき（新記録など）は、その時間いっぱい紙吹雪が
      // 降り続けて見えるよう、降り始めの遅延と枚数を時間に合わせて伸ばす。
      _durationSeconds = override;
      // 紙片1枚が画面外へ落ちきるおおよその時間。これを終端から差し引いた
      // 範囲に降り始めを散らすと、最後まで途切れず降り続ける。
      const fallSeconds = 1.9;
      maxDelay = math.max(0.6, override - fallSeconds);
      // 1秒あたりの枚数（密度）を保ちつつ、長く出すほど総数を増やす。
      count = (maxDelay * 80).round().clamp(120, 600);
      topSpread = 0.45;
    } else {
      count = widget.intense ? 260 : 120;
      _durationSeconds = widget.intense ? 5.5 : 3.4;
      maxDelay = widget.intense ? 2.6 : 0.6;
      // 新記録時は画面の上半分からも降り出し、より早く全体を埋める。
      topSpread = widget.intense ? 0.45 : 0.12;
    }

    _confetti = List.generate(count, (i) {
      final shape =
          _ConfettoShape.values[rnd.nextInt(_ConfettoShape.values.length)];
      return _Confetto(
        x0: rnd.nextDouble(),
        y0: -0.06 - rnd.nextDouble() * topSpread,
        delay: rnd.nextDouble() * maxDelay,
        vx: (rnd.nextDouble() - 0.5) * 0.36,
        vy0: 0.05 + rnd.nextDouble() * 0.22,
        size: 7 + rnd.nextDouble() * (widget.intense ? 12 : 9),
        color: _palette[rnd.nextInt(_palette.length)],
        rotation: rnd.nextDouble() * math.pi * 2,
        rotationSpeed: (rnd.nextDouble() - 0.5) * 11,
        wobbleAmp: rnd.nextDouble() * 0.045,
        wobbleFreq: 2 + rnd.nextDouble() * 3,
        shape: shape,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_durationSeconds * 1000).round()),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _ConfettiPainter(
                confetti: _confetti,
                timeSeconds: _controller.value * _durationSeconds,
                gravity: _gravity,
              ),
            );
          },
        ),
      ),
    );
  }
}

enum _ConfettoShape { rectangle, circle, strip }

/// 紙片1枚分のパラメータ。座標は画面サイズに対する正規化値（0.0〜1.0）。
class _Confetto {
  final double x0; // 初期X
  final double y0; // 初期Y（画面上端の少し上から）
  final double delay; // 降り始めるまでの遅延（秒）
  final double vx; // 横方向の速度（画面幅/秒）
  final double vy0; // 初速（画面高さ/秒）
  final double size; // 1辺のサイズ（px）
  final Color color;
  final double rotation; // 初期回転
  final double rotationSpeed; // 回転速度（rad/秒）
  final double wobbleAmp; // 横揺れの振幅
  final double wobbleFreq; // 横揺れの周波数
  final _ConfettoShape shape;

  const _Confetto({
    required this.x0,
    required this.y0,
    required this.delay,
    required this.vx,
    required this.vy0,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.wobbleAmp,
    required this.wobbleFreq,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetto> confetti;
  final double timeSeconds;
  final double gravity;

  _ConfettiPainter({
    required this.confetti,
    required this.timeSeconds,
    required this.gravity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final c in confetti) {
      final t = timeSeconds - c.delay;
      if (t < 0) continue;

      // 位置を計算（横は等速＋揺れ、縦は等加速度）。
      final nx =
          c.x0 + c.vx * t + c.wobbleAmp * math.sin(c.wobbleFreq * t + c.x0 * 6);
      final ny = c.y0 + c.vy0 * t + 0.5 * gravity * t * t;

      final dx = nx * size.width;
      final dy = ny * size.height;

      // 画面外まで落ちきった紙片は描かない。
      if (dy > size.height + c.size) continue;

      final angle = c.rotation + c.rotationSpeed * t;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(angle);
      paint.color = c.color;

      switch (c.shape) {
        case _ConfettoShape.circle:
          canvas.drawCircle(Offset.zero, c.size * 0.42, paint);
          break;
        case _ConfettoShape.strip:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero,
                  width: c.size * 0.45,
                  height: c.size * 1.4),
              Radius.circular(c.size * 0.2),
            ),
            paint,
          );
          break;
        case _ConfettoShape.rectangle:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero, width: c.size, height: c.size * 0.66),
              Radius.circular(c.size * 0.15),
            ),
            paint,
          );
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.timeSeconds != timeSeconds;
}

/// 新記録のときに大きくポップインし、その後ゆっくり脈動して注目を集めるバナー。
class NewRecordBanner extends StatefulWidget {
  final String text;

  const NewRecordBanner({super.key, required this.text});

  @override
  State<NewRecordBanner> createState() => _NewRecordBannerState();
}

class _NewRecordBannerState extends State<NewRecordBanner>
    with TickerProviderStateMixin {
  // 出現時のポップイン（バウンドしながら拡大）。
  late final AnimationController _popController;
  late final Animation<double> _pop;

  // 出現後の脈動（ゆっくり拡大・縮小を繰り返して目立たせる）。
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _pop = CurvedAnimation(parent: _popController, curve: Curves.elasticOut);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _pulse = Tween(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ポップインが終わってから脈動を始める。
    _popController.forward().whenComplete(() {
      if (mounted) _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _popController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pop, _pulse]),
      builder: (context, child) {
        // elasticOut は 1.0 を少し超えるため、出始めだけ透明度を上げる。
        final opacity = _pop.value.clamp(0.0, 1.0);
        // 出現中はポップインの値、出現後は脈動の値でスケールする。
        final scale = _popController.isCompleted ? _pulse.value : _pop.value;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: DefColor.select,
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Text(
          widget.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: DefColor.textWhite,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            fontFeatures: [FontFeature.proportionalFigures()],
          ),
        ),
      ),
    );
  }
}
