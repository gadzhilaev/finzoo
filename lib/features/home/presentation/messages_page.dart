import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import 'widgets/svg_scene_page.dart';

/// Экран сообщений (макет `Сообщения.svg`).
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key, this.onBack, this.onOpenBook});

  final VoidCallback? onBack;
  final VoidCallback? onOpenBook;

  @override
  Widget build(BuildContext context) {
    return SvgScenePage(
      asset: AppAssets.messages,
      backgroundColor: const Color(0xFFFFFFFF),
      hits: [
        SvgHitArea(
          left: 24,
          top: 65,
          width: 36,
          height: 36,
          onTap: () => onBack?.call(),
        ),
        // Кнопка книжки справа внизу.
        SvgHitArea(
          left: 316.5,
          top: 778.5,
          width: 44,
          height: 44,
          onTap: () => onOpenBook?.call(),
        ),
      ],
    );
  }
}
