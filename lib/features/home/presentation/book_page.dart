import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/layout/design_scale.dart';
import '../../onboarding/presentation/widgets/intro_floating_icons.dart';
import '../../onboarding/presentation/widgets/onboarding_decor.dart';

/// Экран книжки: кружки декора сзади, контейнер сверху, внутри плавают
/// заголовок / письмо / карточки (белка стоит).
class BookPage extends StatelessWidget {
  const BookPage({super.key, this.onOpenHouse});

  final VoidCallback? onOpenHouse;

  static const _floating = <IntroFloatingIcon>[
    IntroFloatingIcon(
      asset: AppAssets.bookTitle,
      x: 59,
      y: 148,
      width: 276,
      height: 51,
      phase: 0.3,
      drift: 5,
      pulse: 0.03,
      speed: 1.0,
    ),
    IntroFloatingIcon(
      asset: AppAssets.bookCurve,
      x: 273,
      y: 218,
      width: 98,
      height: 72,
      phase: 1.4,
      drift: 6,
      pulse: 0.04,
      speed: 1.15,
    ),
    IntroFloatingIcon(
      asset: AppAssets.bookLetter,
      x: 24,
      y: 255,
      width: 162,
      height: 219,
      phase: 2.1,
      drift: 7,
      pulse: 0.04,
      speed: 1.05,
    ),
    IntroFloatingIcon(
      asset: AppAssets.bookLeaf,
      x: 315,
      y: 438,
      width: 36,
      height: 34,
      phase: 0.8,
      drift: 8,
      pulse: 0.08,
      speed: 1.3,
    ),
    IntroFloatingIcon(
      asset: AppAssets.bookCards,
      x: 21,
      y: 510,
      width: 352,
      height: 183,
      phase: 1.7,
      drift: 4,
      pulse: 0.025,
      speed: 0.95,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF4),
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
                // Кружки за контейнером.
                const Positioned.fill(
                  child: IgnorePointer(child: OnboardingDecor()),
                ),
                // Базовый макет: рамка, белка, шапка, стрелки.
                Positioned.fill(
                  child: SvgPicture.asset(
                    AppAssets.book,
                    fit: BoxFit.fill,
                    width: DesignScale.designWidth,
                    height: DesignScale.designHeight,
                  ),
                ),
                // Живые элементы внутри контейнера (кроме белки).
                const Positioned.fill(
                  child: IgnorePointer(
                    child: IntroFloatingLayer(icons: _floating),
                  ),
                ),
                // Дом
                Positioned(
                  left: 24,
                  top: 70,
                  width: 56,
                  height: 56,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onOpenHouse?.call(),
                    child: const SizedBox.expand(),
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
