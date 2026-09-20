import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../home/presentation/home_placeholder_page.dart';
import '../../onboarding/presentation/age_page.dart';
import '../../onboarding/presentation/intro_screens.dart';
import '../../onboarding/presentation/name_page.dart';
import '../../onboarding/presentation/outro_video_page.dart';
import '../../onboarding/presentation/widgets/onboarding_canvas.dart';
import '../../onboarding/presentation/widgets/onboarding_decor.dart';

enum _WelcomeStep { play, age, name, tips, video, home }

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  _WelcomeStep _step = _WelcomeStep.play;
  int _tipIndex = 0;
  int? _age;
  String? _name;

  /// Один экземпляр декора на шаги play/age/name.
  final GlobalKey _decorKey = GlobalKey();

  void _goToAge() {
    if (_step != _WelcomeStep.play) return;
    setState(() => _step = _WelcomeStep.age);
  }

  void _goToName(int age) {
    if (_step != _WelcomeStep.age) return;
    setState(() {
      _age = age;
      _step = _WelcomeStep.name;
    });
  }

  void _goToTips(String name) {
    if (_step != _WelcomeStep.name) return;
    setState(() {
      _name = name;
      _tipIndex = 0;
      _step = _WelcomeStep.tips;
    });
  }

  void _tipBack() {
    if (_tipIndex > 0) {
      setState(() => _tipIndex -= 1);
      return;
    }
    setState(() => _step = _WelcomeStep.name);
  }

  void _tipNext() {
    if (_tipIndex < AppAssets.introScreens.length - 1) {
      setState(() => _tipIndex += 1);
      return;
    }
    _goToVideo();
  }

  void _goToVideo() {
    debugPrint('onboarding done: age=$_age name=$_name');
    setState(() => _step = _WelcomeStep.video);
  }

  void _goToHome() {
    setState(() => _step = _WelcomeStep.home);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 550),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      child: switch (_step) {
        _WelcomeStep.tips => IntroScreens(
          key: const ValueKey('tips'),
          index: _tipIndex,
          onBack: _tipBack,
          onSkip: _goToVideo,
          onNext: _tipNext,
        ),
        _WelcomeStep.video => OutroVideoPage(
          key: const ValueKey('video'),
          onFinished: _goToHome,
        ),
        _WelcomeStep.home => const HomePlaceholderPage(key: ValueKey('home')),
        _ => _buildProfileSteps(),
      },
    );
  }

  Widget _buildProfileSteps() {
    final showSquirrel2 = _step != _WelcomeStep.play;

    return OnboardingCanvas(
      key: const ValueKey('profile-steps'),
      decor: TickerMode(enabled: true, child: OnboardingDecor(key: _decorKey)),
      title: switch (_step) {
        _WelcomeStep.play => 'Привет! Построй свою\nфинансовую жизнь со мной',
        _WelcomeStep.age => 'Сколько тебе лет ?',
        _WelcomeStep.name => 'Как тебя зовут ?',
        _ => '',
      },
      characterAsset: showSquirrel2 ? AppAssets.squirrel2 : AppAssets.squirrel,
      characterWidth: showSquirrel2 ? 253 : 252,
      characterHeight: showSquirrel2 ? 297 : 293,
      gapAfterCharacter: showSquirrel2 ? 50 : 33,
      bottom: switch (_step) {
        _WelcomeStep.play => Center(
          key: const ValueKey('play-step'),
          child: _PlayButton(onPressed: _goToAge),
        ),
        _WelcomeStep.age => AgeStep(
          key: const ValueKey('age-step'),
          onNext: _goToName,
        ),
        _WelcomeStep.name => NameStep(
          key: const ValueKey('name-step'),
          onNext: _goToTips,
        ),
        _ => const SizedBox.shrink(),
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
