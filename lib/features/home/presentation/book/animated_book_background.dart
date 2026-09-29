import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/layout/design_scale.dart';

/// Exact decorative circle from `Книжка 1 cтр.svg` (outer décor only).
class _BgSpec {
  const _BgSpec({
    required this.cx,
    required this.cy,
    required this.r,
    this.fill,
    this.stroke,
    this.strokeWidth = 0,
    this.rotateDeg = 0,
    required this.phase,
    required this.driftX,
    required this.driftY,
    required this.durationFactor,
  });

  final double cx;
  final double cy;
  final double r;
  final Color? fill;
  final Color? stroke;
  final double strokeWidth;
  final double rotateDeg;
  final double phase;
  /// Micro-drift in design px (typically ±3…5).
  final double driftX;
  final double driftY;
  final double durationFactor;
}

/// LAYER 1 — декоративный фон из `assets/book/chrome/book_background.svg`
/// (геометрия 1:1 с «Книжка 1 cтр.svg»). Один экземпляр на Book.
class AnimatedBookBackground extends StatefulWidget {
  const AnimatedBookBackground({super.key});

  @override
  State<AnimatedBookBackground> createState() => _AnimatedBookBackgroundState();
}

class _AnimatedBookBackgroundState extends State<AnimatedBookBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Ровно 10 outer circles из Книжка 1 — без придуманных фигур.
  static const _specs = <_BgSpec>[
    _BgSpec(
      cx: -35.7541,
      cy: 673.246,
      r: 53.2459,
      fill: Color(0xFFFCD788),
      phase: 0.0,
      driftX: 3,
      driftY: -4,
      durationFactor: 1.0,
    ),
    _BgSpec(
      cx: -23.9787,
      cy: 673.246,
      r: 52.4779,
      stroke: Color(0xFF000000),
      strokeWidth: 1.53594,
      phase: 0.2,
      driftX: 3,
      driftY: -4,
      durationFactor: 1.0,
    ),
    _BgSpec(
      cx: 416.786,
      cy: 71.7861,
      r: 79.7861,
      fill: Color(0xFFFCD788),
      phase: 1.1,
      driftX: -4,
      driftY: 3,
      durationFactor: 1.15,
    ),
    _BgSpec(
      cx: -3.08555,
      cy: 61.2499,
      r: 31.9144,
      fill: Color(0xFF4B4A48),
      phase: 2.0,
      driftX: 4,
      driftY: -3,
      durationFactor: 0.9,
    ),
    _BgSpec(
      cx: 376.914,
      cy: 826.914,
      r: 31.9144,
      fill: Color(0xFF4B4A48),
      phase: 2.6,
      driftX: -3,
      driftY: -3,
      durationFactor: 1.05,
    ),
    _BgSpec(
      cx: 288.396,
      cy: 13.5536,
      r: 5.30707,
      stroke: Color(0xFF4B946A),
      strokeWidth: 0.624361,
      rotateDeg: 18.8866,
      phase: 3.2,
      driftX: 3,
      driftY: 4,
      durationFactor: 1.2,
    ),
    _BgSpec(
      cx: 75.0695,
      cy: -5.16483,
      r: 22.5832,
      fill: Color(0xFF4B946A),
      phase: 0.7,
      driftX: 4,
      driftY: 3,
      durationFactor: 0.95,
    ),
    _BgSpec(
      cx: 71.9192,
      cy: -10.4168,
      r: 22.058,
      stroke: Color(0xFF4B4A48),
      strokeWidth: 1.05038,
      phase: 0.85,
      driftX: 4,
      driftY: 3,
      durationFactor: 0.95,
    ),
    _BgSpec(
      cx: 399.99,
      cy: 250.99,
      r: 35.99,
      fill: Color(0xFF4B4A48),
      phase: 1.8,
      driftX: -5,
      driftY: 3,
      durationFactor: 1.1,
    ),
    _BgSpec(
      cx: 172.672,
      cy: 28.6719,
      r: 11.9679,
      stroke: Color(0xFF4B4A48),
      strokeWidth: 1.40799,
      phase: 4.0,
      driftX: -3,
      driftY: 4,
      durationFactor: 1.25,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncAnimation();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  void _syncAnimation() {
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _controller.stop();
      _controller.value = 0;
      return;
    }
    if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final sx = constraints.maxWidth / DesignScale.designWidth;
        final sy = constraints.maxHeight / DesignScale.designHeight;
        final scale = math.max(sx, sy);
        final originX =
            (constraints.maxWidth - DesignScale.designWidth * scale) / 2;
        const originY = 0.0;

        Widget circles(double t) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (final s in _specs)
                _circle(
                  s,
                  scale: scale,
                  originX: originX,
                  originY: originY,
                  t: t,
                ),
            ],
          );
        }

        if (reduce) return circles(0);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_controller.value);
            return circles(t);
          },
        );
      },
    );
  }

  Widget _circle(
    _BgSpec s, {
    required double scale,
    required double originX,
    required double originY,
    required double t,
  }) {
    final turn = t * 2 * math.pi * s.durationFactor;
    final dx = math.sin(turn + s.phase) * s.driftX;
    final dy = math.cos(turn + s.phase + 0.6) * s.driftY;
    final size = (s.r * 2 + s.strokeWidth) * scale;
    final left = originX + (s.cx - s.r - s.strokeWidth / 2 + dx) * scale;
    final top = originY + (s.cy - s.r - s.strokeWidth / 2 + dy) * scale;
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: s.rotateDeg * math.pi / 180,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: s.fill,
              border: s.stroke == null
                  ? null
                  : Border.all(
                      color: s.stroke!,
                      width: s.strokeWidth * scale,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
