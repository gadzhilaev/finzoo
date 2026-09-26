import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/game_controller.dart';
import 'widgets/hub_hud_overlay.dart';
import 'widgets/street_sky_layer.dart';
import 'widgets/svg_scene_page.dart';

/// Улица после выбора цели.
class StreetPage extends StatelessWidget {
  const StreetPage({
    super.key,
    required this.controller,
    this.onOpenHouse,
    this.onOpenMessages,
    this.onOpenGames,
  });

  final GameController controller;
  final VoidCallback? onOpenHouse;
  final VoidCallback? onOpenMessages;
  final VoidCallback? onOpenGames;

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
          coverHeaderLabels: false,
          showStreetHeaderIcons: true,
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
        // Сообщения (облачко).
        SvgHitArea(
          left: 328.5,
          top: 387.5,
          width: 44,
          height: 44,
          onTap: () => onOpenMessages?.call(),
        ),
        // Игры (джойстик).
        SvgHitArea(
          left: 328.5,
          top: 447.5,
          width: 44,
          height: 44,
          onTap: () => onOpenGames?.call(),
        ),
      ],
    );
  }
}
