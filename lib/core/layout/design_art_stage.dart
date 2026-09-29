import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Прозрачная кнопка в координатах макета (viewBox), поверх масштабируемого арта.
class DesignHit {
  const DesignHit({
    required this.rect,
    required this.onTap,
    this.semanticsLabel,
  });

  final Rect rect;
  final VoidCallback onTap;
  final String? semanticsLabel;
}

/// Рисует [art] с [BoxFit.contain] и кладёт hit-area в тех же координатах макета.
class DesignArtStage extends StatelessWidget {
  const DesignArtStage({
    super.key,
    required this.designSize,
    required this.art,
    this.hits = const [],
    this.backgroundColor = const Color(0xFFFEFCF4),
  });

  final Size designSize;
  final Widget art;
  final List<DesignHit> hits;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final maxH = constraints.maxHeight;
          final scale = math.min(
            maxW / designSize.width,
            maxH / designSize.height,
          );
          final drawnW = designSize.width * scale;
          final drawnH = designSize.height * scale;
          final dx = (maxW - drawnW) / 2;
          final dy = (maxH - drawnH) / 2;

          return Stack(
            children: [
              Positioned(
                left: dx,
                top: dy,
                width: drawnW,
                height: drawnH,
                child: art,
              ),
              for (final hit in hits)
                Positioned(
                  left: dx + hit.rect.left * scale,
                  top: dy + hit.rect.top * scale,
                  width: hit.rect.width * scale,
                  height: hit.rect.height * scale,
                  child: Semantics(
                    button: true,
                    label: hit.semanticsLabel,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: hit.onTap,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
