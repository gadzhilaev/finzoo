import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/game_controller.dart';
import '../../../core/profile/player_rules.dart';
import '../../../core/theme/app_fonts.dart';

/// Итоги игрового дня: сравнение плана и факта + один совет.
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
                  fontSize: 13,
                  color: const Color(0xFF5B4300),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: SvgPicture.asset(
                  AppAssets.squirrel,
                  height: 96,
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
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF7E6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1B6943), width: 1.5),
                ),
                child: Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 1.35,
                    color: const Color(0xFF4A4643),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Остаток ${p.availableBalance} ₽ переносится в новый день.',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
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
            Text(
              label,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: const Color(0xFF4A4643),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Планировали $plan ₽  ·  Получилось $fact ₽',
              style: AppFonts.rubik(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: over ? const Color(0xFFDF9548) : const Color(0xFF1B6943),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
