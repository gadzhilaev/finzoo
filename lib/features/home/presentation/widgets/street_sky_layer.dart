import 'package:flutter/material.dart';

/// Солнце стоит, облака едут справа налево без наложения.
class StreetSkyLayer extends StatefulWidget {
  const StreetSkyLayer({super.key});

  @override
  State<StreetSkyLayer> createState() => _StreetSkyLayerState();
}

class _StreetSkyLayerState extends State<StreetSkyLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _clouds = <_CloudSpec>[
    _CloudSpec(lane: 0, width: 110, height: 42, top: 132, speed: 1.0),
    _CloudSpec(lane: 1, width: 88, height: 34, top: 178, speed: 0.72),
    _CloudSpec(lane: 2, width: 100, height: 38, top: 208, speed: 1.25),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 36),
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
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned(
              left: 72,
              top: 118,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFCD788),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x66FFAE00),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: SizedBox(width: 64, height: 64),
                ),
              ),
            ),
            for (final cloud in _clouds) _buildCloud(cloud),
          ],
        );
      },
    );
  }

  Widget _buildCloud(_CloudSpec cloud) {
    // Разные полосы: стартуют с разных фаз, едут влево по кругу.
    const travel = 520.0;
    final phase = cloud.lane / _clouds.length;
    final t = (_controller.value * cloud.speed + phase) % 1.0;
    final left = 400 - t * travel;

    return Positioned(
      left: left,
      top: cloud.top,
      child: IgnorePointer(
        child: Container(
          width: cloud.width,
          height: cloud.height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(cloud.height),
          ),
        ),
      ),
    );
  }
}

class _CloudSpec {
  const _CloudSpec({
    required this.lane,
    required this.width,
    required this.height,
    required this.top,
    required this.speed,
  });

  final int lane;
  final double width;
  final double height;
  final double top;
  final double speed;
}
