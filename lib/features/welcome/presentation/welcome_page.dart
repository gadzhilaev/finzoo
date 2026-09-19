import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../onboarding/presentation/age_page.dart';
import '../../onboarding/presentation/widgets/onboarding_canvas.dart';

enum _WelcomeStep { intro, age }

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  _WelcomeStep _step = _WelcomeStep.intro;

  void _goToAge() {
    if (_step == _WelcomeStep.age) return;
    setState(() => _step = _WelcomeStep.age);
  }

  @override
  Widget build(BuildContext context) {
    final isAge = _step == _WelcomeStep.age;

    return OnboardingCanvas(
      title: isAge
          ? 'Сколько тебе лет ?'
          : 'Привет! Построй свою\nфинансовую жизнь со мной',
      characterAsset: isAge ? AppAssets.squirrel2 : AppAssets.squirrel,
      characterWidth: isAge ? 253 : 252,
      characterHeight: isAge ? 297 : 293,
      gapAfterCharacter: isAge ? 50 : 33,
      bottom: isAge
          ? AgeStep(key: const ValueKey('age-step'), onNext: (_) {})
          : Center(
              key: const ValueKey('play-step'),
              child: _PlayButton(onPressed: _goToAge),
            ),
    );
  }
}

/// Зелёная форма крутится бесконечно, треугольник на месте.
class _PlayButton extends StatefulWidget {
  const _PlayButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 172,
        height: 172,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: child,
                ),
                SvgPicture.asset(
                  AppAssets.playTriangle,
                  width: 172,
                  height: 172,
                  fit: BoxFit.contain,
                ),
              ],
            );
          },
          child: SvgPicture.asset(
            AppAssets.playBlob,
            width: 172,
            height: 172,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
