import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/app_assets.dart';

/// Облака из макета улицы: стартуют как в SVG и едут влево без пауз.
/// Одинаковая скорость — дистанция между облаками как в макете.
class StreetSkyLayer extends StatefulWidget {
  const StreetSkyLayer({super.key, this.animationsEnabled = true});

  final bool animationsEnabled;

  @override
  State<StreetSkyLayer> createState() => _StreetSkyLayerState();
}

class _StreetSkyLayerState extends State<StreetSkyLayer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  /// Родные позиции. Скорость общая, чтобы не схлопывались.
  static const _speedPx = 18.0;
  static const _cycle = 560.0;

  static const _clouds = <_CloudSpec>[
    _CloudSpec(
      asset: AppAssets.streetCloudRight,
      homeX: 189,
      homeY: 116,
      width: 185,
      height: 78,
      fullCanvas: true,
    ),
    // Левое — из Downloads/облако.svg
    _CloudSpec(
      asset: AppAssets.streetCloudLeft,
      homeX: -5,
      homeY: 155,
      width: 153,
      height: 61,
      fullCanvas: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() => _elapsed = elapsed);
    });
    if (widget.animationsEnabled) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant StreetSkyLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationsEnabled == widget.animationsEnabled) return;
    if (widget.animationsEnabled) {
      if (!_ticker.isActive) _ticker.start();
    } else {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _elapsed.inMicroseconds / 1e6;
    final offset = (seconds * _speedPx) % _cycle;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final cloud in _clouds) ...[
          _cloudAt(cloud, cloud.homeX - offset),
          _cloudAt(cloud, cloud.homeX - offset + _cycle),
        ],
      ],
    );
  }

  Widget _cloudAt(_CloudSpec cloud, double left) {
    final picture = cloud.fullCanvas
        ? OverflowBox(
            maxWidth: 393,
            maxHeight: 852,
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: Offset(-cloud.homeX, -cloud.homeY),
              child: SvgPicture.asset(
                cloud.asset,
                width: 393,
                height: 852,
                fit: BoxFit.fill,
              ),
            ),
          )
        : SvgPicture.asset(
            cloud.asset,
            width: cloud.width,
            height: cloud.height,
            fit: BoxFit.fill,
          );

    return Positioned(
      left: left,
      top: cloud.homeY,
      width: cloud.width,
      height: cloud.height,
      child: IgnorePointer(child: picture),
    );
  }
}

class _CloudSpec {
  const _CloudSpec({
    required this.asset,
    required this.homeX,
    required this.homeY,
    required this.width,
    required this.height,
    required this.fullCanvas,
  });

  final String asset;
  final double homeX;
  final double homeY;
  final double width;
  final double height;
  final bool fullCanvas;
}
