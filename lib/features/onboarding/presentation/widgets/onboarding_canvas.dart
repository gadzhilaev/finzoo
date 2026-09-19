import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/layout/design_scale.dart';
import '../../../../core/theme/app_colors.dart';
import 'onboarding_decor.dart';

/// Общий холст онбординга 393×852 с плавной сменой контента.
class OnboardingCanvas extends StatelessWidget {
  const OnboardingCanvas({
    super.key,
    required this.title,
    required this.characterAsset,
    required this.bottom,
    this.characterWidth = 252,
    this.characterHeight = 293,
    this.characterLeft = 94,
    this.characterTop = 296,
    this.gapAfterCharacter = 33,
    this.transitionDuration = const Duration(milliseconds: 550),
  });

  final String title;
  final String characterAsset;
  final Widget bottom;
  final double characterWidth;
  final double characterHeight;
  final double characterLeft;
  final double characterTop;
  final double gapAfterCharacter;
  final Duration transitionDuration;

  @override
  Widget build(BuildContext context) {
    final bottomTop = characterTop + characterHeight + gapAfterCharacter;

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
                const OnboardingDecor(),
                Positioned(
                  top: 145,
                  left: 94,
                  child: SvgPicture.asset(
                    AppAssets.logo2,
                    width: 203,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 224,
                  left: 0,
                  right: 0,
                  child: _FadeSlideSwitcher(
                    duration: transitionDuration,
                    child: Text(
                      title,
                      key: ValueKey(title),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontWeight: FontWeight.w700,
                        fontSize: 21,
                        height: 1,
                        letterSpacing: -0.52,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: transitionDuration,
                  curve: Curves.easeInOutCubic,
                  top: characterTop,
                  left: characterLeft,
                  child: _FadeSlideSwitcher(
                    duration: transitionDuration,
                    child: SvgPicture.asset(
                      characterAsset,
                      key: ValueKey(characterAsset),
                      width: characterWidth,
                      height: characterHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: transitionDuration,
                  curve: Curves.easeInOutCubic,
                  top: bottomTop,
                  left: 0,
                  right: 0,
                  child: _FadeSlideSwitcher(
                    duration: transitionDuration,
                    child: KeyedSubtree(
                      key: ValueKey(bottom.runtimeType),
                      child: bottom,
                    ),
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

class _FadeSlideSwitcher extends StatelessWidget {
  const _FadeSlideSwitcher({required this.child, required this.duration});

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            ?currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(fade);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: child,
    );
  }
}
