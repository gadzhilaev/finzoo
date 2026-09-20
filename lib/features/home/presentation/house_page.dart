import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/game_controller.dart';
import 'widgets/hub_hud_overlay.dart';
import 'widgets/svg_scene_page.dart';

/// Дом — обычный вид или с раскрытой целью накопления.
class HousePage extends StatelessWidget {
  const HousePage({
    super.key,
    required this.controller,
    this.savedExpanded = false,
    this.onOpenStreet,
    this.onOpenBook,
    this.onToggleSaved,
  });

  final GameController controller;
  final bool savedExpanded;
  final VoidCallback? onOpenStreet;
  final VoidCallback? onOpenBook;
  final VoidCallback? onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return SvgScenePage(
      asset: savedExpanded ? AppAssets.houseSaved : AppAssets.house,
      backgroundColor: const Color(0xFFFEFCF4),
      overlays: [
        HubHudOverlay(
          controller: controller,
          showSavedCard: true,
          balanceTop: 130,
          onCompleteTask: () => controller.completeDailyTask(),
        ),
      ],
      hits: [
        SvgHitArea(
          left: 17,
          top: 448,
          width: 45,
          height: 45,
          onTap: () => onOpenStreet?.call(),
        ),
        SvgHitArea(
          left: 328,
          top: 448,
          width: 50,
          height: 45,
          onTap: () => onOpenBook?.call(),
        ),
        SvgHitArea(
          left: 201,
          top: 130,
          width: 178,
          height: 58,
          onTap: () => onToggleSaved?.call(),
        ),
      ],
    );
  }
}
