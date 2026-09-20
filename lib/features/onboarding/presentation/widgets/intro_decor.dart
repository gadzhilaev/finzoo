import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Живые кружки для ознакомительных экранов.
class IntroDecor extends StatefulWidget {
  const IntroDecor({super.key});

  @override
  State<IntroDecor> createState() => _IntroDecorState();
}

class _IntroSpec {
  const _IntroSpec({
    required this.cx,
    required this.cy,
    required this.r,
    this.fill,
    this.stroke,
    this.strokeWidth = 0,
    required this.phase,
    required this.pulseAmp,
    required this.driftX,
    required this.driftY,
    required this.pulseCycles,
    required this.driftXCycles,
    required this.driftYCycles,
  });

  final double cx;
  final double cy;
  final double r;
  final Color? fill;
  final Color? stroke;
  final double strokeWidth;
  final double phase;
  final double pulseAmp;
  final double driftX;
  final double driftY;
  final int pulseCycles;
  final int driftXCycles;
  final int driftYCycles;
}

class _IntroDecorState extends State<IntroDecor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _specs = <_IntroSpec>[
    _IntroSpec(
      cx: 416.79,
      cy: 71.79,
      r: 79.79,
      fill: Color(0xFFFCD788),
      phase: 0.4,
      pulseAmp: 0.07,
      driftX: -8,
      driftY: 6,
      pulseCycles: 1,
      driftXCycles: 1,
      driftYCycles: 2,
    ),
    _IntroSpec(
      cx: 413.79,
      cy: 833.79,
      r: 79.29,
      stroke: Color(0xFF4B4A48),
      strokeWidth: 1.2,
      phase: 1.1,
      pulseAmp: 0.06,
      driftX: -6,
      driftY: -5,
      pulseCycles: 1,
      driftXCycles: 2,
      driftYCycles: 1,
    ),
    _IntroSpec(
      cx: 288.40,
      cy: 13.55,
      r: 5.31,
      stroke: AppColors.green,
      strokeWidth: 0.62,
      phase: 2.0,
      pulseAmp: 0.18,
      driftX: 3,
      driftY: 4,
      pulseCycles: 3,
      driftXCycles: 2,
      driftYCycles: 3,
    ),
    _IntroSpec(
      cx: 171.10,
      cy: -2.91,
      r: 11.97,
      stroke: Color(0xFF4B4A48),
      strokeWidth: 1.41,
      phase: 0.8,
      pulseAmp: 0.14,
      driftX: -3,
      driftY: 5,
      pulseCycles: 3,
      driftXCycles: 2,
      driftYCycles: 1,
    ),
    _IntroSpec(
      cx: 14.01,
      cy: 752.01,
      r: 10.33,
      stroke: Color(0xFF4B4A48),
      strokeWidth: 1.41,
      phase: 1.6,
      pulseAmp: 0.14,
      driftX: 4,
      driftY: -4,
      pulseCycles: 2,
      driftXCycles: 1,
      driftYCycles: 2,
    ),
    _IntroSpec(
      cx: 404.99,
      cy: 528.99,
      r: 35.99,
      fill: Color(0xFF4B4A48),
      phase: 2.4,
      pulseAmp: 0.09,
      driftX: -7,
      driftY: -5,
      pulseCycles: 1,
      driftXCycles: 2,
      driftYCycles: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final turn = _controller.value * 2 * math.pi;
        return Stack(
          clipBehavior: Clip.none,
          children: [for (final spec in _specs) _buildCircle(spec, turn)],
        );
      },
    );
  }

  Widget _buildCircle(_IntroSpec spec, double turn) {
    final scale =
        1 + math.sin(turn * spec.pulseCycles + spec.phase) * spec.pulseAmp;
    final dx =
        math.sin(turn * spec.driftXCycles + spec.phase + 0.6) * spec.driftX;
    final dy =
        math.cos(turn * spec.driftYCycles + spec.phase + 1.1) * spec.driftY;
    final size = (spec.r * 2 + spec.strokeWidth) * scale;

    return Positioned(
      left: spec.cx - size / 2 + dx,
      top: spec.cy - size / 2 + dy,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: spec.fill,
            border: spec.stroke == null
                ? null
                : Border.all(
                    color: spec.stroke!,
                    width: spec.strokeWidth * scale,
                  ),
          ),
        ),
      ),
    );
  }
}
