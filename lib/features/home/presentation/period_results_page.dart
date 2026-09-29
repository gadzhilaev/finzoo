import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/game_controller.dart';
import '../../../core/profile/player_profile.dart';
import '../../../core/profile/player_rules.dart';
import '../../../core/theme/app_fonts.dart';

/// Итоги игрового дня: сравнение плана и факта + рост + совет.
class PeriodResultsPage extends StatelessWidget {
  const PeriodResultsPage({
    super.key,
    required this.controller,
    required this.onNextPeriod,
  });

  final GameController controller;
  final VoidCallback onNextPeriod;

  @override
  Widget build(BuildContext context) {
    final p = controller.profile;
    final plan = p.plan;
    final hint = PlayerRules.periodVerdict(
      planNecessary: plan?.necessary ?? 0,
      planWants: plan?.wants ?? 0,
      planSavings: plan?.savings ?? 0,
      spentNecessary: p.spentNecessary,
      spentWants: p.spentWants,
      factSavings: p.factSavings,
      careUses: p.periodCareUses,
      satiety: p.satiety,
    );
    final growthGain = PlayerRules.growthPointsForPeriod(
      planNecessary: plan?.necessary ?? 0,
      planWants: plan?.wants ?? 0,
      planSavings: plan?.savings ?? 0,
      spentNecessary: p.spentNecessary,
      spentWants: p.spentWants,
      factSavings: p.factSavings,
      careUses: p.periodCareUses,
    );
    // Очки уже начислены в finishPeriod — объясняем по факту дня.
    final growthText = PlayerRules.growthGainExplanation(
      gain: growthGain,
      planNecessary: plan?.necessary ?? 0,
      planWants: plan?.wants ?? 0,
      planSavings: plan?.savings ?? 0,
      spentNecessary: p.spentNecessary,
      spentWants: p.spentWants,
      factSavings: p.factSavings,
      careUses: p.periodCareUses,
    );
    final stateText = _stateLine(p);

    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Как прошёл день',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: const Color(0xFF1B6943),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'День с Finzo · ${p.periodIndex}',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFF5B4300),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        AppAssets.squirrel,
                        height: 88,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (plan != null) ...[
                      _CompareRow(
                        label: 'Необходимое',
                        plan: plan.necessary,
                        fact: p.spentNecessary,
                      ),
                      _CompareRow(
                        label: 'Желания',
                        plan: plan.wants,
                        fact: p.spentWants,
                      ),
                      _CompareRow(
                        label: 'Накопления',
                        plan: plan.savings,
                        fact: p.factSavings,
                      ),
                    ],
                    const SizedBox(height: 10),
                    _InfoCard(
                      icon: Icons.trending_up_rounded,
                      text: growthText,
                      accent: const Color(0xFF1B6943),
                    ),
                    if (stateText != null) ...[
                      const SizedBox(height: 8),
                      _InfoCard(
                        icon: Icons.favorite_rounded,
                        text: stateText,
                        accent: const Color(0xFFDF9548),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _InfoCard(
                      icon: Icons.lightbulb_outline_rounded,
                      text: hint,
                      accent: const Color(0xFF1B6943),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Остаток ${p.availableBalance} ₽ переносится в новый день.',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFF5B4300),
                ),
              ),
              const SizedBox(height: 14),
              Material(
                color: const Color(0xFF4B946A),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () async {
                    final ok = await controller.startNextPeriod();
                    if (ok) onNextPeriod();
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 52,
                    child: Center(
                      child: Text(
                        'Новый день',
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _stateLine(PlayerProfile p) {
    final plan = p.plan;
    if (plan != null && plan.wants > 0 && p.spentWants > plan.wants) {
      return 'Finzo чуть расстроился: на желания ушло больше, '
          'чем было в плане (${plan.wants} ₽ → ${p.spentWants} ₽).';
    }
    if (p.satiety < 40) {
      return 'Сытость Finzo низкая (${p.satiety.round()}%): '
          'сегодня мало еды или ухода.';
    }
    if (p.mood < 40) {
      return 'Настроение Finzo снижено (${p.mood.round()}%): '
          'помогут уход, наряд или спокойный план завтра.';
    }
    return null;
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.text,
    required this.accent,
  });

  final IconData icon;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF7E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                height: 1.35,
                color: const Color(0xFF4A4643),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.plan,
    required this.fact,
  });

  final String label;
  final int plan;
  final int fact;

  @override
  Widget build(BuildContext context) {
    final over = fact > plan;
    final under = fact < plan;
    final statusLabel = over
        ? 'Больше плана'
        : (under ? 'Меньше плана' : 'Как в плане');
    final statusIcon = over
        ? Icons.arrow_upward_rounded
        : (under ? Icons.arrow_downward_rounded : Icons.check_rounded);
    final statusColor = over
        ? const Color(0xFFDF9548)
        : (under ? const Color(0xFF5B4300) : const Color(0xFF1B6943));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF7E6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1B6943)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppFonts.rubik(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: const Color(0xFF4A4643),
                    ),
                  ),
                ),
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Планировали $plan ₽  ·  Получилось $fact ₽',
              style: AppFonts.rubik(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: const Color(0xFF4A4643),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
