import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/budget_plan.dart';
import '../../../core/profile/game_controller.dart';
import '../../home/presentation/book_page.dart';
import '../../home/presentation/adult_page.dart';
import '../../home/presentation/budget_plan_page.dart';
import '../../home/presentation/financial_task_page.dart';
import '../../home/presentation/games_page.dart';
import '../../home/presentation/goals_page.dart';
import '../../home/presentation/house_page.dart';
import '../../home/presentation/messages_page.dart';
import '../../home/presentation/practice/practice_catalog.dart';
import '../../home/presentation/period_results_page.dart';
import '../../home/presentation/street_page.dart';
import '../../onboarding/presentation/age_page.dart';
import '../../onboarding/presentation/intro_screens.dart';
import '../../onboarding/presentation/name_page.dart';
import '../../onboarding/presentation/pet_setup_page.dart';
import '../../onboarding/presentation/outro_video_page.dart';
import '../../onboarding/presentation/widgets/onboarding_canvas.dart';
import '../../onboarding/presentation/widgets/onboarding_decor.dart';

enum _WelcomeStep {
  play,
  age,
  name,
  petSetup,
  tips,
  video,
  home,
  street,
  house,
  book,
  games,
  messages,
  budget,
  task,
  results,
  goals,
  adult,
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, required this.game});

  final GameController game;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with WidgetsBindingObserver {
  late _WelcomeStep _step;
  int _tipIndex = 0;
  late int _age;
  late String _name;
  late String _petName;
  int _starterLook = 0;
  _WelcomeStep? _messagesReturnStep;
  String? _parkFocusId;
  bool _parkSkipIntro = false;
  bool _bookStartToc = false;
  int? _bookStartPage;

  final GlobalKey _decorKey = GlobalKey();

  GameController get _game => widget.game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final p = _game.profile;
    _age = p.age;
    _name = p.name;
    _petName = p.petName;
    const shot = String.fromEnvironment('UI_SHOT');
    if (shot == 'house' ||
        shot == 'available' ||
        shot == 'saved' ||
        shot == 'sleep' ||
        shot == 'savings' ||
        (shot.startsWith('wardrobe') && !shot.contains('street'))) {
      _step = _WelcomeStep.house;
    } else if (shot.startsWith('wardrobe') && shot.contains('street')) {
      _step = _WelcomeStep.street;
    } else if (shot.startsWith('play_')) {
      // play_practice_lunch / play_park_bike → сразу задание
      _step = _WelcomeStep.games;
      _parkFocusId = PracticeCatalog.resolveOpenId(
        shot.substring('play_'.length),
      );
      _parkSkipIntro = true;
    } else if (shot == 'games' ||
        shot.startsWith('park_') ||
        shot.startsWith('practice_')) {
      _step = _WelcomeStep.games;
      if (shot.startsWith('park_') || shot.startsWith('practice_')) {
        _parkFocusId = PracticeCatalog.resolveOpenId(shot);
      }
    } else if (shot == 'book' ||
        shot == 'book_toc' ||
        shot == 'book_rule' ||
        shot.startsWith('book_')) {
      _step = _WelcomeStep.book;
      if (shot == 'book_toc') {
        _bookStartToc = true;
      } else if (shot == 'book_rule') {
        _bookStartPage = 1;
      } else if (shot == 'book_last') {
        _bookStartPage = 999; // clamp to last in BookPage
      } else if (RegExp(r'^book_\d+$').hasMatch(shot)) {
        final n = int.tryParse(shot.substring('book_'.length));
        if (n != null && n >= 1) _bookStartPage = n - 1;
      }
    } else if (shot == 'budget') {
      _step = _WelcomeStep.budget;
    } else if (shot == 'task') {
      _step = _WelcomeStep.task;
    } else if (shot == 'results') {
      _step = _WelcomeStep.results;
    } else if (!p.onboardingDone) {
      _step = _WelcomeStep.play;
    } else if (p.periodPhase == PeriodPhase.results) {
      _step = _WelcomeStep.results;
    } else if (p.needsBudgetPlan) {
      _step = _WelcomeStep.budget;
    } else {
      _step = _WelcomeStep.street;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_game.syncStats());
    }
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

  Future<void> _goToPetSetup([String? name]) async {
    if (_step != _WelcomeStep.name) return;
    final nextName = (name ?? _name).trim();
    if (nextName.isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _name = nextName;
      _step = _WelcomeStep.petSetup;
    });
    // Не ждём диск — иначе UI может «зависнуть» на SharedPreferences.
    unawaited(_game.setIdentity(name: nextName, age: _age));
  }

  Future<void> _goToTips(String petName, StarterLook look) async {
    _petName = petName.trim().isEmpty ? 'Finzo' : petName.trim();
    _starterLook = starterLooks.indexOf(look);
    _tipIndex = 0;
    await _game.setPetIdentity(
      petName: _petName,
      starterBodyKey: look.bodyKey,
      starterHeadKey: look.headKey,
    );
    if (mounted) setState(() => _step = _WelcomeStep.tips);
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
      goalImageAsset: goal.imageAsset,
      petName: _petName,
      starterBodyKey: starterLooks[_starterLook].bodyKey,
      starterHeadKey: starterLooks[_starterLook].headKey,
    );
    if (!mounted) return;
    setState(() => _step = _WelcomeStep.budget);
  }

  void _goToHouse() => setState(() => _step = _WelcomeStep.house);

  void _goToBook() => setState(() => _step = _WelcomeStep.book);

  void _goToStreetOnly() {
    final p = _game.profile;
    if (p.periodPhase == PeriodPhase.results) {
      setState(() => _step = _WelcomeStep.results);
    } else if (p.needsBudgetPlan) {
      setState(() => _step = _WelcomeStep.budget);
    } else {
      setState(() => _step = _WelcomeStep.street);
    }
  }

  void _goToGames() => setState(() {
    _parkFocusId = null;
    _parkSkipIntro = false;
    _step = _WelcomeStep.games;
  });

  void _goToMessagesFrom(_WelcomeStep origin) => setState(() {
    _messagesReturnStep = origin;
    _step = _WelcomeStep.messages;
  });

  void _leaveMessages() {
    final origin = _messagesReturnStep;
    _messagesReturnStep = null;
    setState(() => _step = origin ?? _WelcomeStep.street);
  }

  void _goToBudget() => setState(() => _step = _WelcomeStep.budget);

  void _goToTask() {
    final next = PracticeCatalog.nextIncomplete(
      _game.profile.periodPracticeCompletedIds,
    );
    setState(() {
      _parkFocusId = next.id;
      _parkSkipIntro = false;
      _step = _WelcomeStep.games;
    });
  }

  void _clearParkFocus() {
    if (_parkFocusId == null && !_parkSkipIntro) return;
    setState(() {
      _parkFocusId = null;
      _parkSkipIntro = false;
    });
  }

  void _goToResults() => setState(() => _step = _WelcomeStep.results);

  void _goToGoalPicker() => setState(() => _step = _WelcomeStep.goals);

  Future<void> _chooseNextGoal(GoalOption goal) async {
    final price =
        int.tryParse(goal.price.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    await _game.chooseGoal(
      title: goal.title.replaceAll('\n', ' '),
      price: price,
      imageAsset: goal.imageAsset,
    );
    if (mounted) _goToStreetOnly();
  }

  Future<void> _goToAdult() async {
    final answer = TextEditingController();
    final passed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Раздел для взрослого'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Решите пример: 8 + 7 ='),
            const SizedBox(height: 10),
            TextField(
              controller: answer,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Назад'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, answer.text.trim() == '15'),
            child: const Text('Открыть'),
          ),
        ],
      ),
    );
    answer.dispose();
    if (passed == true && mounted) setState(() => _step = _WelcomeStep.adult);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _game.profile.animationsEnabled
          ? const Duration(milliseconds: 550)
          : Duration.zero,
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
        _WelcomeStep.petSetup => PetSetupPage(
          key: const ValueKey('pet-setup'),
          playerName: _name,
          initialPetName: _petName,
          initialLook: _starterLook,
          onBack: () => setState(() => _step = _WelcomeStep.name),
          onDone: _goToTips,
        ),
        _WelcomeStep.video => OutroVideoPage(
          key: const ValueKey('video'),
          onFinished: _goToHome,
        ),
        _WelcomeStep.home => GoalsPage(
          key: const ValueKey('home'),
          onGoalConfirmed: _goToStreet,
        ),
        _WelcomeStep.street => StreetPage(
          key: const ValueKey('street'),
          controller: _game,
          onOpenHouse: _goToHouse,
          onOpenMessages: () => _goToMessagesFrom(_WelcomeStep.street),
          onOpenGames: _goToGames,
          onOpenBudget: _goToBudget,
          onOpenTask: _goToTask,
          onOpenResults: _goToResults,
          onChooseNextGoal: _goToGoalPicker,
          onOpenAdult: () => unawaited(_goToAdult()),
        ),
        _WelcomeStep.budget => BudgetPlanPage(
          key: const ValueKey('budget'),
          controller: _game,
          onConfirmed: _goToStreetOnly,
          onBack: _game.profile.canPlayPeriod
              ? () => setState(() => _step = _WelcomeStep.street)
              : null,
        ),
        _WelcomeStep.task => FinancialTaskPage(
          key: const ValueKey('task'),
          controller: _game,
          onDone: _goToStreetOnly,
        ),
        _WelcomeStep.results => PeriodResultsPage(
          key: const ValueKey('results'),
          controller: _game,
          onNextPeriod: () => setState(() => _step = _WelcomeStep.budget),
        ),
        _WelcomeStep.goals => GoalsPage(
          key: const ValueKey('goals'),
          title: 'Выбери новую цель',
          onBack: _goToStreetOnly,
          onGoalConfirmed: _chooseNextGoal,
        ),
        _WelcomeStep.adult => AdultPage(
          key: const ValueKey('adult'),
          controller: _game,
          onBack: _goToStreetOnly,
          onResetDone: () => setState(() => _step = _WelcomeStep.play),
        ),
        _WelcomeStep.house => HousePage(
          key: const ValueKey('house'),
          controller: _game,
          onOpenStreet: _goToStreetOnly,
          onOpenMessages: () => _goToMessagesFrom(_WelcomeStep.house),
          onOpenBook: _goToBook,
          onOpenResults: _goToResults,
          onChooseNextGoal: _goToGoalPicker,
          onOpenAdult: () => unawaited(_goToAdult()),
        ),
        _WelcomeStep.book => BookPage(
          key: const ValueKey('book'),
          onOpenHouse: _goToHouse,
          startAtToc: _bookStartToc,
          startPage: _bookStartPage,
          onOpenParkGame: (id) => setState(() {
            _parkFocusId = PracticeCatalog.resolveOpenId(id);
            _parkSkipIntro = false;
            _step = _WelcomeStep.games;
          }),
        ),
        _WelcomeStep.games => GamesPage(
          key: ValueKey('games-${_parkFocusId ?? 'map'}'),
          controller: _game,
          onBack: () {
            _clearParkFocus();
            _goToStreetOnly();
          },
          autoOpenExerciseId: _parkFocusId,
          skipIntro: _parkSkipIntro,
          onAutoOpenConsumed: _clearParkFocus,
        ),
        _WelcomeStep.messages => MessagesPage(
          key: const ValueKey('messages'),
          controller: _game,
          onBack: _leaveMessages,
          onOpenBook: _goToBook,
          onOpenHouse: _goToHouse,
          onOpenGames: _goToGames,
          onOpenBudget: _goToBudget,
          onOpenAdult: () => unawaited(_goToAdult()),
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
          onNext: (name) => unawaited(_goToPetSetup(name)),
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
