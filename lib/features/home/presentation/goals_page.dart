import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';

/// Цель накопления — картинка лежит в [imageAsset].
class GoalOption {
  const GoalOption({
    required this.price,
    required this.title,
    required this.imageAsset,
    required this.imageLeft,
    required this.imageTop,
    required this.imageSize,
    required this.priceLeft,
    required this.priceTop,
    required this.priceWidth,
  });

  final String price;
  final String title;
  final String imageAsset;

  /// Локальные координаты внутри карточки 192×226 — из `4 экран.svg`.
  final double imageLeft;
  final double imageTop;
  final double imageSize;
  final double priceLeft;
  final double priceTop;
  final double priceWidth;
}

/// Экран «На что ты хочешь накопить» — 1:1 с макетом `4 экран.svg`.
class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key, this.onGoalConfirmed});

  final ValueChanged<GoalOption>? onGoalConfirmed;

  /// Координаты из SVG: карточка origin (10|201, 217+row*199).
  static const goals = <GoalOption>[
    GoalOption(
      price: '800 ₽',
      title: 'Велосипед',
      imageAsset: AppAssets.goalBicycle,
      imageLeft: 43.5,
      imageTop: 54,
      imageSize: 105,
      priceLeft: 31,
      priceTop: 44,
      priceWidth: 69,
    ),
    GoalOption(
      price: '300 ₽',
      title: 'Наушники',
      imageAsset: AppAssets.goalHeadphones,
      imageLeft: 52,
      imageTop: 69,
      imageSize: 88,
      priceLeft: 31,
      priceTop: 43,
      priceWidth: 65,
    ),
    GoalOption(
      price: '1200 ₽',
      title: 'Плейстейшн',
      imageAsset: AppAssets.goalPlaystation,
      imageLeft: 52.5,
      imageTop: 72,
      imageSize: 87,
      priceLeft: 32,
      priceTop: 44,
      priceWidth: 79,
    ),
    GoalOption(
      price: '1500 ₽',
      title: 'Лодка',
      imageAsset: AppAssets.goalBoat,
      imageLeft: 43.5,
      imageTop: 57,
      imageSize: 105,
      priceLeft: 31,
      priceTop: 43,
      priceWidth: 79,
    ),
    GoalOption(
      price: '500 ₽',
      title: 'Теннисная\nракетка',
      imageAsset: AppAssets.goalTennis,
      imageLeft: 52,
      imageTop: 68,
      imageSize: 88,
      priceLeft: 32,
      priceTop: 42,
      priceWidth: 79,
    ),
    GoalOption(
      price: '400 ₽',
      title: 'Удочка',
      imageAsset: AppAssets.goalFishing,
      imageLeft: 43.5,
      imageTop: 59,
      imageSize: 105,
      priceLeft: 31,
      priceTop: 42,
      priceWidth: 65,
    ),
  ];

  /// Макет Figma: 393 × 943.
  static const designWidth = 393.0;
  static const designHeight = 943.0;

  static const cardW = 192.0;
  static const cardH = 226.0;
  static const cardLeftEven = 10.0;
  static const cardLeftOdd = 201.0;
  static const cardTop0 = 217.0;
  static const cardRowStep = 199.0;

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  int? _selectedIndex;

  void _confirm() {
    final i = _selectedIndex;
    if (i == null) return;
    widget.onGoalConfirmed?.call(GoalsPage.goals[i]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Весь макет 393×943 целиком, по центру — как SVG.
          final scale = math.min(
            constraints.maxWidth / GoalsPage.designWidth,
            constraints.maxHeight / GoalsPage.designHeight,
          );
          final w = GoalsPage.designWidth * scale;
          final h = GoalsPage.designHeight * scale;

          return ColoredBox(
            color: AppColors.cream,
            child: Center(
              child: SizedBox(
                width: w,
                height: h,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: SizedBox(
                    width: GoalsPage.designWidth,
                    height: GoalsPage.designHeight,
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        // Логотип по центру.
                        Positioned(
                          top: 115,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SvgPicture.asset(
                              AppAssets.logoIntro,
                              width: 153,
                              height: 45,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 186,
                          left: 24,
                          right: 24,
                          child: Text(
                            'На что ты хочешь накопить?',
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
                        for (var i = 0; i < GoalsPage.goals.length; i++)
                          Positioned(
                            left: i.isEven
                                ? GoalsPage.cardLeftEven
                                : GoalsPage.cardLeftOdd,
                            top:
                                GoalsPage.cardTop0 +
                                (i ~/ 2) * GoalsPage.cardRowStep,
                            width: GoalsPage.cardW,
                            height: GoalsPage.cardH,
                            child: _GoalCard(
                              goal: GoalsPage.goals[i],
                              selected: _selectedIndex == i,
                              onTap: () => setState(() => _selectedIndex = i),
                            ),
                          ),
                        // «Ок» — из макета (объём + текст).
                        Positioned(
                          left: 244,
                          top: 838,
                          width: 120,
                          height: 71.45,
                          child: _OkButton(
                            enabled: _selectedIndex != null,
                            onTap: _confirm,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.selected, this.onTap});

  final GoalOption goal;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              selected ? AppAssets.goalsCardSelected : AppAssets.goalsCard,
              fit: BoxFit.fill,
            ),
          ),
          // Картинка под ценой.
          Positioned(
            left: goal.imageLeft,
            top: goal.imageTop,
            width: goal.imageSize,
            height: goal.imageSize,
            child: Image.asset(
              goal.imageAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: Color(0x33DE984D)),
            ),
          ),
          Positioned(
            left: goal.priceLeft,
            top: goal.priceTop,
            width: goal.priceWidth,
            height: 22,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                child: Text(
                  goal.price,
                  maxLines: 1,
                  style: GoogleFonts.rubik(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    height: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 42,
            child: Text(
              goal.title,
              maxLines: 2,
              textAlign: TextAlign.center,
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

class _OkButton extends StatelessWidget {
  const _OkButton({required this.enabled, this.onTap});

  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.45,
        child: SvgPicture.asset(
          AppAssets.okButton,
          width: 120,
          height: 71.45,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
