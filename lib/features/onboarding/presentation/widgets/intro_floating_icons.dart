import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IntroFloatingIcon {
  const IntroFloatingIcon({
    required this.asset,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.phase = 0,
    this.drift = 6,
    this.pulse = 0.04,
    this.speed = 1,
  });

  final String asset;
  final double x;
  final double y;
  final double width;
  final double height;
  final double phase;
  final double drift;
  final double pulse;
  final double speed;
}

/// Иконки, вырезанные из макетов ознакомительных экранов.
abstract final class IntroFloatingIcons {
  static const screen1 = <IntroFloatingIcon>[
    IntroFloatingIcon(
      asset: 'assets/images/intro_icons/intro_1_clip6_148_832.svg',
      x: 121,
      y: 281,
      width: 199,
      height: 238,
      phase: 0.2,
      drift: 5,
      pulse: 0.02,
      speed: 0.8,
    ),
    IntroFloatingIcon(
      asset: 'assets/images/intro_icons/intro_1_clip4_148_832.svg',
      x: 47,
      y: 531,
      width: 41,
      height: 35,
      phase: 1.1,
      drift: 8,
      pulse: 0.08,
      speed: 1.2,
    ),
    IntroFloatingIcon(
      asset: 'assets/images/intro_icons/intro_1_clip3_148_832.svg',
      x: 263,
      y: 533,
      width: 69,
      height: 65,
      phase: 2.0,
      drift: 7,
      pulse: 0.07,
      speed: 1.1,
    ),
    IntroFloatingIcon(
      asset: 'assets/images/intro_icons/intro_1_clip5_148_832.svg',
      x: 337,
      y: 405,
      width: 41,
      height: 35,
      phase: 0.7,
      drift: 9,
      pulse: 0.09,
      speed: 1.3,
    ),
  ];

  static const screen2 = <IntroFloatingIcon>[
    IntroFloatingIcon(
      asset: 'assets/images/intro_icons/intro_2_clip3_150_1063.svg',
      x: 268,
      y: 269,
      width: 95,
      height: 102,
      phase: 0.4,
      drift: 6,
      pulse: 0.05,
      speed: 1.0,
    ),
    IntroFloatingIcon(
      asset: 'assets/images/intro_icons/intro_2_clip4_150_1063.svg',
      x: 36,
      y: 269,
      width: 34,
      height: 34,
      phase: 1.4,
      drift: 7,
      pulse: 0.08,
      speed: 1.2,
    ),
    IntroFloatingIcon(
      asset: 'assets/images/intro_icons/intro_2_clip5_150_1063.svg',
      x: 10,
      y: 440,
      width: 51,
      height: 48,
      phase: 2.2,
      drift: 8,
      pulse: 0.07,
      speed: 1.1,
    ),
    IntroFloatingIcon(
      asset: 'assets/images/intro_icons/intro_2_clip6_150_1063.svg',
      x: 24,
      y: 366,
      width: 24,
      height: 46,
      phase: 0.9,
      drift: 6,
      pulse: 0.06,
      speed: 1.25,
    ),
    IntroFloatingIcon(
      asset: 'assets/images/intro_icons/intro_2_clip7_150_1063.svg',
      x: 50,
      y: 511,
      width: 16,
      height: 17,
      phase: 1.8,
      drift: 5,
      pulse: 0.1,
      speed: 1.4,
    ),
    IntroFloatingIcon(
      asset: 'assets/images/intro_icons/intro_2_clip9_150_1063.svg',
      x: 294,
      y: 511,
      width: 46,
      height: 46,
      phase: 0.3,
      drift: 7,
      pulse: 0.07,
      speed: 1.15,
    ),
    IntroFloatingIcon(
      asset: 'assets/images/intro_icons/intro_2_clip8_150_1063.svg',
      x: 300,
      y: 610,
      width: 80,
      height: 77,
      phase: 2.5,
      drift: 5,
      pulse: 0.05,
      speed: 0.95,
    ),
  ];

  static const screen3 = <IntroFloatingIcon>[
    IntroFloatingIcon(
      asset: 'assets/images/intro_icons/intro_3_bang.svg',
      x: 155,
      y: 290,
      width: 90,
      height: 230,
      phase: 0.5,
      drift: 8,
      pulse: 0.04,
      speed: 1.0,
    ),
  ];

  static List<IntroFloatingIcon> forIndex(int index) {
    return switch (index) {
      0 => screen1,
      1 => screen2,
      _ => screen3,
    };
  }
}

class IntroFloatingLayer extends StatefulWidget {
  const IntroFloatingLayer({super.key, required this.icons});

  final List<IntroFloatingIcon> icons;

  @override
  State<IntroFloatingLayer> createState() => _IntroFloatingLayerState();
}

class _IntroFloatingLayerState extends State<IntroFloatingLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
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
          children: [for (final icon in widget.icons) _buildIcon(icon, turn)],
        );
      },
    );
  }

  Widget _buildIcon(IntroFloatingIcon icon, double turn) {
    // Целые циклы — без рывка на стыке repeat().
    final dy =
        math.sin(turn * icon.speed.round().clamp(1, 3) + icon.phase) *
        icon.drift;
    final dx = math.cos(turn + icon.phase + 0.4) * (icon.drift * 0.35);
    final scale = 1 + math.sin(turn * 2 + icon.phase) * icon.pulse;

    return Positioned(
      left: icon.x + dx,
      top: icon.y + dy,
      width: icon.width,
      height: icon.height,
      child: IgnorePointer(
        child: Transform.scale(
          scale: scale,
          child: OverflowBox(
            maxWidth: 393,
            maxHeight: 852,
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: Offset(-icon.x, -icon.y),
              child: SvgPicture.asset(
                icon.asset,
                width: 393,
                height: 852,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Полоски прогресса — живут отдельно от смены экрана, плавно морфятся.
class IntroProgressBars extends StatelessWidget {
  const IntroProgressBars({super.key, required this.activeIndex});

  final int activeIndex;

  static const _active = Color(0xFF1B6943);
  static const _idle = Color(0xFFD9D9D9);
  static const _duration = Duration(milliseconds: 420);

  @override
  Widget build(BuildContext context) {
    final index = activeIndex.clamp(0, 2);

    return Positioned(
      top: 74,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            AnimatedContainer(
              duration: _duration,
              curve: Curves.easeInOutCubic,
              width: i == index ? 61 : 33,
              height: 12,
              decoration: BoxDecoration(
                color: i <= index ? _active : _idle,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
