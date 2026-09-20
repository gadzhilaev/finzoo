import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/profile/game_controller.dart';
import '../../../../core/profile/player_rules.dart';
import '../../../../core/theme/app_colors.dart';

/// Живые данные поверх SVG: имя, стрик, балансы, сытость/настроение.
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.profile;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 58,
              top: 68,
              width: 150,
              height: 28,
              child: ColoredBox(
                color: const Color(0xFFFCF9F6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    p.name.isEmpty ? 'Друг' : p.name,
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
            ),
            Positioned(
              left: 218,
              top: 62,
              child: _StreakBadge(days: p.streakDays),
            ),
            Positioned(
              left: showSavedCard ? 14 : 22,
              top: balanceTop,
              width: showSavedCard ? 177 : 137,
              height: 58,
              child: _BalanceCard(
                title: 'Доступно',
                titleColor: const Color(0xFFCD5E2A),
                value: p.availableBalance,
              ),
            ),
            if (showSavedCard)
              Positioned(
                left: 202,
                top: balanceTop,
                width: 177,
                height: 58,
                child: _BalanceCard(
                  title: 'Накоплено',
                  titleColor: AppColors.green,
                  value: p.savedBalance,
                ),
              ),
            Positioned(
              left: 12.5,
              top: 534.5,
              width: 368,
              height: 55,
              child: _StatsBar(satiety: p.satiety, mood: p.mood),
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
    final flameScale = (1.0 + (days.clamp(0, 30) / 30) * 0.85).clamp(1.0, 1.85);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 108),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0x1ACD5E2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x8ACD5E2A)),
          ),
          child: Text(
            PlayerRules.streakLabel(days),
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1,
              color: const Color(0xFFCD5E2A),
            ),
          ),
        ),
        const SizedBox(width: 4),
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.title,
    required this.titleColor,
    required this.value,
  });

  final String title;
  final Color titleColor;
  final int value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF7E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDC9A55), width: 0.9),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.rubik(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                height: 1,
                color: titleColor,
              ),
            ),
            const Spacer(),
            Text(
              '$value',
              style: GoogleFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                height: 1,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.satiety, required this.mood});

  final double satiety;
  final double mood;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.5),
        border: Border.all(color: const Color(0xFF1B6943)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _StatColumn(
                label: 'Сытость',
                value: satiety,
                barColor: const Color(0xFF1B6943),
                textColor: const Color(0xFF1B6943),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatColumn(
                label: 'Настроение',
                value: mood,
                barColor: const Color(0xFFE8A87C),
                textColor: const Color(0xFFCD5E2A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.barColor,
    required this.textColor,
  });

  final String label;
  final double value;
  final Color barColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final pct = value.round().clamp(0, 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                height: 1,
                color: textColor,
              ),
            ),
            const Spacer(),
            Text(
              '$pct%',
              style: GoogleFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                height: 1,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFFEDE8E2),
            color: barColor,
          ),
        ),
      ],
    );
  }
}
