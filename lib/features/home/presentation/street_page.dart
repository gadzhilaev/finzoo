import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/game_controller.dart';
import 'widgets/hub_hud_overlay.dart';
import 'widgets/street_sky_layer.dart';
import 'widgets/svg_scene_page.dart';

/// Улица после выбора цели.
class StreetPage extends StatelessWidget {
  const StreetPage({super.key, required this.controller, this.onOpenHouse});

  final GameController controller;
  final VoidCallback? onOpenHouse;

  @override
  Widget build(BuildContext context) {
    return SvgScenePage(
      asset: AppAssets.street,
      backgroundColor: const Color(0xFFD7F9FF),
      overlays: [
        const StreetSkyLayer(),
        HubHudOverlay(
          controller: controller,
          showSavedCard: false,
          balanceTop: 221,
          onCompleteTask: () => controller.completeDailyTask(),
        ),
      ],
      hits: [
        SvgHitArea(
          left: 17,
          top: 447,
          width: 45,
          height: 45,
          onTap: () => onOpenHouse?.call(),
        ),
      ],
    );
  }
}
