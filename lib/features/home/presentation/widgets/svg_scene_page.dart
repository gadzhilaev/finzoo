import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/layout/design_scale.dart';

/// Полноэкранная сцена 393×852 из SVG + оверлеи + прозрачные зоны нажатия.
class SvgScenePage extends StatelessWidget {
  const SvgScenePage({
    super.key,
    required this.asset,
    required this.backgroundColor,
    this.hits = const [],
    this.underlays = const [],
    this.overlays = const [],
  });

  final String asset;
  final Color backgroundColor;
  final List<SvgHitArea> hits;

  /// Слой под SVG (например PNG-фон, который flutter_svg не рисует из pattern).
  final List<Widget> underlays;
  final List<Widget> overlays;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: DesignScale.designWidth,
            height: DesignScale.designHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ...underlays,
                Positioned.fill(
                  child: SvgPicture.asset(
                    asset,
                    fit: BoxFit.fill,
                    width: DesignScale.designWidth,
                    height: DesignScale.designHeight,
                  ),
                ),
                ...overlays,
                for (final hit in hits)
                  Positioned(
                    left: hit.left,
                    top: hit.top,
                    width: hit.width,
                    height: hit.height,
                    child: Semantics(
                      button: true,
                      label: hit.semanticsLabel,
                      child: GestureDetector(
                        onTap: hit.onTap,
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SvgHitArea {
  const SvgHitArea({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.onTap,
    this.semanticsLabel,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final VoidCallback onTap;
  final String? semanticsLabel;
}
