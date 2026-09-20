import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import 'widgets/svg_scene_page.dart';

/// Экран книжки / урока.
class BookPage extends StatelessWidget {
  const BookPage({super.key, this.onOpenHouse});

  final VoidCallback? onOpenHouse;

  @override
  Widget build(BuildContext context) {
    return SvgScenePage(
      asset: AppAssets.book,
      backgroundColor: const Color(0xFFFEFCF4),
      hits: [
        // Иконка дома слева сверху.
        SvgHitArea(
          left: 24,
          top: 70,
          width: 56,
          height: 56,
          onTap: () => onOpenHouse?.call(),
        ),
      ],
    );
  }
}
