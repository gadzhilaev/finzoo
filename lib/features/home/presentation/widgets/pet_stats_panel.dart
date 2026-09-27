import 'package:flutter/material.dart';

import '../../../../core/profile/game_controller.dart';
import '../../../../core/profile/player_rules.dart';
import '../../../../core/theme/app_fonts.dart';

/// Сытость и настроение в одной светлой панели с зелёной обводкой.
class PetStatsPanel extends StatelessWidget {
  const PetStatsPanel({
    super.key,
    required this.controller,
    this.top = 528,
    this.moodDeltaFlash,
  });

  final GameController controller;
  final double top;

  /// Неблокирующий прирост настроения рядом со шкалой (после первого надевания).
  final double? moodDeltaFlash;

  static const double height = 56;

  void _showTip(BuildContext context, {required bool satiety}) {
    final title = satiety ? 'Сытость' : 'Настроение';
    final body = satiety
        ? 'Сытость медленно падает со временем '
            '(около ${PlayerRules.satietyDecayPerHour} в час). '
            'Покорми Finzo едой из дома — кухня. '
            'Низкая сытость — не наказание, просто сигнал: пора поесть.'
        : 'Настроение падает медленнее сытости '
            '(около ${PlayerRules.moodDecayPerHour} в час). '
            'Поднять его помогают одежда (один раз на вещь), душ и забота. '
            'Плохое настроение не забирает прогресс.';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFFEF7E6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          16 + MediaQuery.paddingOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: const Color(0xFF1B6943),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.35,
                color: const Color(0xFF4A4643),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4B946A),
                minimumSize: const Size.fromHeight(44),
              ),
              child: Text(
                'Понятно',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.profile;
        return Positioned(
          left: 12,
          right: 12,
          top: top,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF7E6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1B6943), width: 1.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _showTip(context, satiety: true),
                    borderRadius: BorderRadius.circular(8),
                    child: _StatColumn(
                      label: 'Сытость',
                      percent: p.satiety,
                      fill: const Color(0xFF1B6943),
                      border: const Color(0xFF1B6943),
                      icon: Icons.restaurant_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _showTip(context, satiety: false),
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _StatColumn(
                          label: 'Настроение',
                          percent: p.mood,
                          fill: const Color(0xFFFDD889),
                          border: const Color(0xFFDE984D),
                          icon: Icons.sentiment_satisfied_alt_rounded,
                          percentColor: const Color(0xFFCD5E2A),
                        ),
                        if (moodDeltaFlash != null && moodDeltaFlash! > 0)
                          Positioned(
                            right: 0,
                            top: -10,
                            child: Text(
                              '+${moodDeltaFlash!.round()}',
                              style: AppFonts.rubik(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: const Color(0xFF1B6943),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.percent,
    required this.fill,
    required this.border,
    required this.icon,
    this.percentColor,
  });

  final String label;
  final double percent;
  final Color fill;
  final Color border;
  final IconData icon;
  final Color? percentColor;

  @override
  Widget build(BuildContext context) {
    final pct = percent.round().clamp(0, 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: percentColor ?? fill),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: const Color(0xFF4A4643),
                ),
              ),
            ),
            Text(
              '$pct%',
              style: AppFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: percentColor ?? fill,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.2),
              child: FractionallySizedBox(
                widthFactor: (percent / 100).clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
