import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import 'widgets/svg_scene_page.dart';

/// Парк мини-игр (макет `игры.svg`).
/// Фон — PNG: flutter_svg не рисует встроенную картинку из `<pattern>`.
class GamesPage extends StatelessWidget {
  const GamesPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SvgScenePage(
      asset: AppAssets.games,
      backgroundColor: const Color(0xFFFFFFFF),
      underlays: const [
        Positioned(
          left: -26,
          top: 0,
          width: 450,
          height: 852,
          child: Image(
            image: AssetImage(AppAssets.gamesBg),
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ],
      hits: [
        SvgHitArea(
          left: 24,
          top: 65,
          width: 36,
          height: 36,
          onTap: () => onBack?.call(),
        ),
      ],
    );
  }
}
