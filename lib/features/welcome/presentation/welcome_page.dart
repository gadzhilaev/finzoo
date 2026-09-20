import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../onboarding/presentation/age_page.dart';
import '../../onboarding/presentation/name_page.dart';
import '../../onboarding/presentation/widgets/onboarding_canvas.dart';
import '../../onboarding/presentation/widgets/onboarding_decor.dart';

enum _WelcomeStep { intro, age, name }

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  _WelcomeStep _step = _WelcomeStep.intro;
  int? _age;

  /// Один экземпляр декора на весь онбординг — анимация не перезапускается.
  final GlobalKey _decorKey = GlobalKey();

  void _goToAge() {
    if (_step != _WelcomeStep.intro) return;
    setState(() => _step = _WelcomeStep.age);
  }

  void _goToName(int age) {
    if (_step != _WelcomeStep.age) return;
    setState(() {
      _age = age;
      _step = _WelcomeStep.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showSquirrel2 = _step != _WelcomeStep.intro;

    return OnboardingCanvas(
      decor: TickerMode(enabled: true, child: OnboardingDecor(key: _decorKey)),
      title: switch (_step) {
        _WelcomeStep.intro => 'Привет! Построй свою\nфинансовую жизнь со мной',
        _WelcomeStep.age => 'Сколько тебе лет ?',
        _WelcomeStep.name => 'Как тебя зовут ?',
      },
      characterAsset: showSquirrel2 ? AppAssets.squirrel2 : AppAssets.squirrel,
      characterWidth: showSquirrel2 ? 253 : 252,
      characterHeight: showSquirrel2 ? 297 : 293,
      gapAfterCharacter: showSquirrel2 ? 50 : 33,
      bottom: switch (_step) {
        _WelcomeStep.intro => Center(
          key: const ValueKey('play-step'),
          child: _PlayButton(onPressed: _goToAge),
        ),
        _WelcomeStep.age => AgeStep(
          key: const ValueKey('age-step'),
          onNext: _goToName,
        ),
        _WelcomeStep.name => NameStep(
          key: const ValueKey('name-step'),
          onNext: (name) {
            debugPrint('onboarding: age=$_age name=$name');
          },
        ),
      },
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
