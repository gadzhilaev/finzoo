import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/layout/design_scale.dart';
import '../../../core/theme/app_colors.dart';
import '../../onboarding/presentation/widgets/onboarding_decor.dart';

/// Цель накопления — картинка лежит в [imageAsset].
class GoalOption {
  const GoalOption({
    required this.price,
    required this.title,
    required this.imageAsset,
  });

  final String price;
  final String title;

  /// Путь к PNG в `assets/images/goals/`. Чтобы заменить картинку —
  /// положи новый файл с тем же именем (или поменяй путь здесь).
  final String imageAsset;
}

/// Экран «На что ты хочешь накопить» — без статусбара, с живыми кругами.
class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key, this.onGoalSelected});

  final ValueChanged<GoalOption>? onGoalSelected;

  static const goals = <GoalOption>[
    GoalOption(
      price: '15.000 ₽',
      title: 'Велосипед',
      imageAsset: AppAssets.goalBicycle,
    ),
    GoalOption(
      price: '5000 ₽',
      title: 'Наушники',
      imageAsset: AppAssets.goalHeadphones,
    ),
    GoalOption(
      price: '65.000 ₽',
      title: 'Плейстейшн',
      imageAsset: AppAssets.goalPlaystation,
    ),
    GoalOption(
      price: '80.000 ₽',
      title: 'Велосипед',
      imageAsset: AppAssets.goalBicycle2,
    ),
    GoalOption(
      price: '10.000 ₽',
      title: 'Теннисная\nракетка',
      imageAsset: AppAssets.goalTennis,
    ),
    GoalOption(
      price: '6000 ₽',
      title: 'Удочка',
      imageAsset: AppAssets.goalFishing,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: DesignScale.designWidth,
            height: DesignScale.designHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(
                  child: IgnorePointer(child: OnboardingDecor()),
                ),
                Positioned(
                  top: 115,
                  left: 94,
                  child: SvgPicture.asset(
                    AppAssets.logo2,
                    width: 203,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 186,
                  left: 24,
                  right: 24,
                  child: Text(
                    'На что ты хочешь накопить',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                      fontWeight: FontWeight.w700,
                      fontSize: 21,
                      height: 1.1,
                      letterSpacing: -0.52,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Positioned(
                  top: 248,
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: Column(
                    children: [
                      for (var row = 0; row < 3; row++) ...[
                        if (row > 0) const SizedBox(height: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _GoalCard(
                                  goal: goals[row * 2],
                                  onTap: () =>
                                      onGoalSelected?.call(goals[row * 2]),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _GoalCard(
                                  goal: goals[row * 2 + 1],
                                  onTap: () =>
                                      onGoalSelected?.call(goals[row * 2 + 1]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, this.onTap});

  final GoalOption goal;
  final VoidCallback? onTap;

  static const _cardFill = Color(0xFFFEF7E6);
  static const _cardStroke = Color(0xFFDE984D);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _cardFill,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _cardStroke, width: 1.2),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                goal.price,
                style: GoogleFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: 28,
            left: 12,
            right: 12,
            bottom: 44,
            child: Image.asset(
              goal.imageAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: Color(0x33DE984D)),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 10,
            child: Text(
              goal.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                height: 1.05,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
