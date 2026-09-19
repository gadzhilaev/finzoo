import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DecorSpec {
  const DecorSpec({
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

class OnboardingDecor extends StatefulWidget {
  const OnboardingDecor({super.key});

  @override
  State<OnboardingDecor> createState() => _OnboardingDecorState();
}

class _OnboardingDecorState extends State<OnboardingDecor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _specs = <DecorSpec>[
    DecorSpec(
      cx: -40.75,
      cy: 205.25,
      r: 53.25,
      fill: Color(0xFFFCD788),
      phase: 0.0,
      pulseAmp: 0.08,
      driftX: 6,
      driftY: 8,
      pulseCycles: 2,
      driftXCycles: 1,
      driftYCycles: 1,
    ),
    DecorSpec(
      cx: -28.98,
      cy: 205.25,
      r: 52.48,
      stroke: Color(0xFF000000),
      strokeWidth: 1.54,
      phase: 0.0,
      pulseAmp: 0.08,
      driftX: 6,
      driftY: 8,
      pulseCycles: 2,
      driftXCycles: 1,
      driftYCycles: 1,
    ),
    DecorSpec(
      cx: 416.79,
      cy: 71.79,
      r: 79.79,
      fill: Color(0xFFFCD788),
      phase: 1.2,
      pulseAmp: 0.07,
      driftX: -8,
      driftY: 6,
      pulseCycles: 1,
      driftXCycles: 1,
      driftYCycles: 2,
    ),
    DecorSpec(
      cx: -3.09,
      cy: 61.25,
      r: 31.91,
      fill: Color(0xFF4B4A48),
      phase: 2.4,
      pulseAmp: 0.1,
      driftX: 7,
      driftY: -5,
      pulseCycles: 2,
      driftXCycles: 2,
      driftYCycles: 1,
    ),
    DecorSpec(
      cx: 104.59,
      cy: 61.68,
      r: 10.33,
      stroke: Color(0xFF4B4A48),
      strokeWidth: 1.41,
      phase: 0.8,
      pulseAmp: 0.14,
      driftX: 4,
      driftY: 5,
      pulseCycles: 3,
      driftXCycles: 2,
      driftYCycles: 2,
    ),
    DecorSpec(
      cx: 240.11,
      cy: 68.11,
      r: 25.11,
      fill: AppColors.green,
      phase: 1.7,
      pulseAmp: 0.11,
      driftX: -5,
      driftY: 6,
      pulseCycles: 2,
      driftXCycles: 1,
      driftYCycles: 2,
    ),
    DecorSpec(
      cx: 288.40,
      cy: 13.55,
      r: 5.31,
      stroke: AppColors.green,
      strokeWidth: 0.62,
      phase: 3.0,
      pulseAmp: 0.18,
      driftX: 3,
      driftY: 4,
      pulseCycles: 3,
      driftXCycles: 2,
      driftYCycles: 3,
    ),
    DecorSpec(
      cx: 75.07,
      cy: -5.16,
      r: 22.58,
      fill: AppColors.green,
      phase: 0.5,
      pulseAmp: 0.09,
      driftX: 5,
      driftY: 4,
      pulseCycles: 2,
      driftXCycles: 1,
      driftYCycles: 2,
    ),
    DecorSpec(
      cx: 71.92,
      cy: -10.42,
      r: 22.06,
      stroke: Color(0xFF4B4A48),
      strokeWidth: 1.05,
      phase: 0.5,
      pulseAmp: 0.09,
      driftX: 5,
      driftY: 4,
      pulseCycles: 2,
      driftXCycles: 1,
      driftYCycles: 2,
    ),
    DecorSpec(
      cx: 399.99,
      cy: 250.99,
      r: 35.99,
      fill: Color(0xFF4B4A48),
      phase: 2.8,
      pulseAmp: 0.09,
      driftX: -7,
      driftY: -6,
      pulseCycles: 1,
      driftXCycles: 2,
      driftYCycles: 1,
    ),
    DecorSpec(
      cx: 171.10,
      cy: -2.91,
      r: 11.97,
      stroke: Color(0xFF4B4A48),
      strokeWidth: 1.41,
      phase: 4.0,
      pulseAmp: 0.16,
      driftX: -3,
      driftY: 5,
      pulseCycles: 3,
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

  Widget _buildCircle(DecorSpec spec, double turn) {
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
