import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/profile/game_controller.dart';
import '../../../../core/profile/player_rules.dart';
import '../../../../core/theme/app_colors.dart';

/// Патчи поверх SVG: имя, стрик, цифры баланса и статусов.
/// Иконки и рамки остаются из макета.
class HubHudOverlay extends StatelessWidget {
  const HubHudOverlay({
    super.key,
    required this.controller,
    required this.showSavedCard,
    this.balanceTop = 221,
    this.onCompleteTask,
  });

  final GameController controller;
  final bool showSavedCard;
  final double balanceTop;
  final VoidCallback? onCompleteTask;

  static const _headerCream = Color(0xFFFCF9F6);
  static const _cardCream = Color(0xFFFEF7E6);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.profile;
        final name = p.name.isEmpty ? 'Друг' : p.name;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Закрываем только SVG-имя (логотип-лис остаётся в макете).
            Positioned(
              left: 58,
              top: 58,
              width: 155,
              height: 36,
              child: ColoredBox(color: _headerCream),
            ),
            Positioned(
              left: 70,
              top: 66,
              width: 140,
              height: 24,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rubik(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    height: 1,
                    color: AppColors.green,
                  ),
                ),
              ),
            ),
            // Стрик: закрываем макетный бейдж целиком.
            Positioned(
              left: 220,
              top: 60,
              width: 165,
              height: 36,
              child: ColoredBox(color: _headerCream),
            ),
            Positioned(
              left: 224,
              top: 64,
              child: _StreakBadge(days: p.streakDays),
            ),
            // Только цифры баланса — иконки из SVG.
            Positioned(
              left: showSavedCard ? 88 : 78,
              top: balanceTop + 26,
              width: showSavedCard ? 90 : 70,
              height: 28,
              child: ColoredBox(
                color: _cardCream,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${p.availableBalance}',
                    style: GoogleFonts.rubik(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      height: 1,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            if (showSavedCard)
              Positioned(
                left: 276,
                top: balanceTop + 26,
                width: 90,
                height: 28,
                child: ColoredBox(
                  color: const Color(0xFFEBF4EE),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${p.savedBalance}',
                      style: GoogleFonts.rubik(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        height: 1,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            // Проценты и полоски — иконки/подписи из SVG.
            Positioned(
              left: 148,
              top: 542,
              width: 42,
              height: 18,
              child: ColoredBox(
                color: Colors.white,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${p.satiety.round()}%',
                    style: GoogleFonts.rubik(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1,
                      color: const Color(0xFF1B6943),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 325,
              top: 542,
              width: 42,
              height: 18,
              child: ColoredBox(
                color: Colors.white,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${p.mood.round()}%',
                    style: GoogleFonts.rubik(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1,
                      color: const Color(0xFFCD5E2A),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 25.5,
              top: 567.5,
              width: 164.5,
              height: 9,
              child: _MiniBar(
                value: p.satiety / 100,
                fill: const Color(0xFF1B6943),
                border: const Color(0xFF1B6943),
              ),
            ),
            Positioned(
              left: 203,
              top: 567.5,
              width: 164.5,
              height: 9,
              child: _MiniBar(
                value: p.mood / 100,
                fill: const Color(0xFFFDD889),
                border: const Color(0xFFDE984D),
              ),
            ),
            if (onCompleteTask != null)
              Positioned(
                left: 54,
                top: 740,
                width: 285,
                height: 56,
                child: GestureDetector(
                  onTap: onCompleteTask,
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox.expand(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final flameScale = (1.0 + (days.clamp(0, 30) / 30) * 0.7).clamp(1.0, 1.7);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 25,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0x1ACD5E2A),
            borderRadius: BorderRadius.circular(12.5),
            border: Border.all(color: const Color(0x8ACD5E2A), width: 1),
          ),
          child: Text(
            PlayerRules.streakLabel(days),
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1,
              color: const Color(0xFFCD5E2A),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Transform.scale(
          scale: flameScale,
          alignment: Alignment.bottomCenter,
          child: const Icon(
            Icons.local_fire_department_rounded,
            color: Color(0xFFE85A00),
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({
    required this.value,
    required this.fill,
    required this.border,
  });

  final double value;
  final Color fill;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.5),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          alignment: Alignment.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
