import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/layout/design_scale.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/intro_decor.dart';
import 'widgets/intro_floating_icons.dart';

/// Три ознакомительных экрана: chrome сверху/снизу статичен, контент листается.
class IntroScreens extends StatefulWidget {
  const IntroScreens({
    super.key,
    required this.index,
    required this.onBack,
    required this.onSkip,
    required this.onNext,
  });

  final int index;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  State<IntroScreens> createState() => _IntroScreensState();
}

class _IntroScreensState extends State<IntroScreens> {
  final GlobalKey _decorKey = GlobalKey();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index.clamp(0, 2));
  }

  @override
  void didUpdateWidget(covariant IntroScreens oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.index.clamp(0, 2);
    if (oldWidget.index != widget.index && _pageController.hasClients) {
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.index.clamp(0, 2);

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
                Positioned.fill(
                  child: IgnorePointer(
                    child: TickerMode(
                      enabled: true,
                      child: IntroDecor(key: _decorKey),
                    ),
                  ),
                ),
                // Только внутренний контент листается — без fade/затемнения.
                Positioned.fill(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: AppAssets.introScreens.length,
                    itemBuilder: (context, pageIndex) {
                      return _IntroPageContent(
                        asset: AppAssets.introScreens[pageIndex],
                        index: pageIndex,
                      );
                    },
                  ),
                ),
                IntroProgressBars(activeIndex: index),
                Positioned(
                  left: 24,
                  top: 65,
                  child: _HitArea(width: 36, height: 36, onTap: widget.onBack),
                ),
                Positioned(
                  right: 16,
                  top: 65,
                  child: _HitArea(width: 90, height: 36, onTap: widget.onSkip),
                ),
                Positioned(
                  left: 54,
                  top: 719,
                  child: _HitArea(width: 285, height: 66, onTap: widget.onNext),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroPageContent extends StatelessWidget {
  const _IntroPageContent({required this.asset, required this.index});

  final String asset;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        SvgPicture.asset(
          asset,
          fit: BoxFit.fill,
          width: DesignScale.designWidth,
          height: DesignScale.designHeight,
        ),
        if (index == 0)
          const Positioned.fill(
            child: IgnorePointer(child: IntroMarchingDashes()),
          ),
        IntroFloatingLayer(icons: IntroFloatingIcons.forIndex(index)),
      ],
    );
  }
}

class _HitArea extends StatelessWidget {
  const _HitArea({
    required this.width,
    required this.height,
    required this.onTap,
  });

  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(width: width, height: height),
    );
  }
}
