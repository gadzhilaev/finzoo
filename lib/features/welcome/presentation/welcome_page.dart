import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/game_controller.dart';
import '../../home/presentation/book_page.dart';
import '../../home/presentation/goals_page.dart';
import '../../home/presentation/house_page.dart';
import '../../home/presentation/street_page.dart';
import '../../onboarding/presentation/age_page.dart';
import '../../onboarding/presentation/intro_screens.dart';
import '../../onboarding/presentation/name_page.dart';
import '../../onboarding/presentation/outro_video_page.dart';
import '../../onboarding/presentation/widgets/onboarding_canvas.dart';
import '../../onboarding/presentation/widgets/onboarding_decor.dart';

enum _WelcomeStep {
  play,
  age,
  name,
  tips,
  video,
  home,
  street,
  house,
  houseSaved,
  book,
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, required this.game});

  final GameController game;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late _WelcomeStep _step;
  int _tipIndex = 0;
  late int _age;
  late String _name;

  final GlobalKey _decorKey = GlobalKey();

  GameController get _game => widget.game;

  @override
  void initState() {
    super.initState();
    final p = _game.profile;
    _age = p.age;
    _name = p.name;
    _step = p.onboardingDone ? _WelcomeStep.street : _WelcomeStep.play;
  }

  void _goToAge() {
    if (_step != _WelcomeStep.play) return;
    setState(() => _step = _WelcomeStep.age);
  }

  void _goToName([int? age]) {
    if (_step != _WelcomeStep.age && _step != _WelcomeStep.tips) return;
    setState(() {
      if (age != null) _age = age;
      _step = _WelcomeStep.name;
    });
  }

  Future<void> _goToTips([String? name]) async {
    if (_step != _WelcomeStep.name) return;
    final nextName = (name ?? _name).trim();
    if (nextName.isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _name = nextName;
      _tipIndex = 0;
      _step = _WelcomeStep.tips;
    });
    // Не ждём диск — иначе UI может «зависнуть» на SharedPreferences.
    unawaited(_game.setIdentity(name: nextName, age: _age));
  }

  void _ageBack() {
    setState(() => _step = _WelcomeStep.play);
  }

  void _nameBack() {
    setState(() => _step = _WelcomeStep.age);
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
    setState(() => _step = _WelcomeStep.video);
  }

  void _goToHome() {
    setState(() => _step = _WelcomeStep.home);
  }

  Future<void> _goToStreet(GoalOption goal) async {
    final price =
        int.tryParse(goal.price.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    await _game.completeOnboarding(
      name: _name,
      age: _age,
      goalTitle: goal.title.replaceAll('\n', ' '),
      goalPrice: price,
    );
    if (!mounted) return;
    setState(() => _step = _WelcomeStep.street);
  }

  void _goToHouse() => setState(() => _step = _WelcomeStep.house);

  void _goToHouseSaved() => setState(() => _step = _WelcomeStep.houseSaved);

  void _goToBook() => setState(() => _step = _WelcomeStep.book);

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
        _WelcomeStep.home => GoalsPage(
          key: const ValueKey('home'),
          onGoalSelected: _goToStreet,
        ),
        _WelcomeStep.street => StreetPage(
          key: const ValueKey('street'),
          controller: _game,
          onOpenHouse: _goToHouse,
        ),
        _WelcomeStep.house => HousePage(
          key: const ValueKey('house'),
          controller: _game,
          onOpenStreet: () => setState(() => _step = _WelcomeStep.street),
          onOpenBook: _goToBook,
          onToggleSaved: _goToHouseSaved,
        ),
        _WelcomeStep.houseSaved => HousePage(
          key: const ValueKey('house-saved'),
          controller: _game,
          savedExpanded: true,
          onOpenStreet: () => setState(() => _step = _WelcomeStep.street),
          onOpenBook: _goToBook,
          onToggleSaved: _goToHouse,
        ),
        _WelcomeStep.book => BookPage(
          key: const ValueKey('book'),
          onOpenHouse: _goToHouse,
        ),
        _ => _buildProfileSteps(),
      },
    );
  }

  Widget _buildProfileSteps() {
    final showSquirrel2 = _step != _WelcomeStep.play;

    return OnboardingCanvas(
      key: const ValueKey('profile-steps'),
      decor: TickerMode(enabled: true, child: OnboardingDecor(key: _decorKey)),
      onBack: switch (_step) {
        _WelcomeStep.age => _ageBack,
        _WelcomeStep.name => _nameBack,
        _ => null,
      },
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
          initialAge: _age,
          onChanged: (age) => _age = age,
          onNext: _goToName,
        ),
        _WelcomeStep.name => NameStep(
          key: const ValueKey('name-step'),
          initialName: _name,
          onChanged: (name) => _name = name,
          onNext: (name) => unawaited(_goToTips(name)),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

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
