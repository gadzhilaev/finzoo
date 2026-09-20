import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Солнце и облака медленно плывут по небу на улице.
class StreetSkyLayer extends StatefulWidget {
  const StreetSkyLayer({super.key});

  @override
  State<StreetSkyLayer> createState() => _StreetSkyLayerState();
}

class _StreetSkyLayerState extends State<StreetSkyLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
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
        final t = _controller.value * 2 * math.pi;
        final sunDx = math.sin(t * 0.35) * 18;
        final sunDy = math.cos(t * 0.28) * 10;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 72 + sunDx,
              top: 118 + sunDy,
              child: IgnorePointer(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFCD788),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x66FFAE00),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _cloud(
              left: 200 + math.sin(t * 0.5) * 40,
              top: 140 + math.cos(t * 0.4) * 8,
              width: 120,
              height: 48,
            ),
            _cloud(
              left: 40 + math.cos(t * 0.45) * 30,
              top: 190 + math.sin(t * 0.55) * 10,
              width: 90,
              height: 36,
            ),
            _cloud(
              left: 260 + math.sin(t * 0.3 + 1) * 35,
              top: 200 + math.cos(t * 0.5 + 0.5) * 6,
              width: 100,
              height: 40,
            ),
          ],
        );
      },
    );
  }

  Widget _cloud({
    required double left,
    required double top,
    required double width,
    required double height,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(height),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
