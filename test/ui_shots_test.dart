import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finzoo/core/profile/budget_plan.dart';
import 'package:finzoo/core/profile/economy.dart';
import 'package:finzoo/core/profile/game_controller.dart';
import 'package:finzoo/core/profile/player_profile.dart';
import 'package:finzoo/core/profile/player_profile_store.dart';
import 'package:finzoo/features/home/presentation/book/book_content.dart';
import 'package:finzoo/features/home/presentation/book_page.dart';
import 'package:finzoo/features/home/presentation/budget_plan_page.dart';
import 'package:finzoo/features/home/presentation/financial_task_page.dart';
import 'package:finzoo/features/home/presentation/games_page.dart';
import 'package:finzoo/features/home/presentation/practice/practice_catalog.dart';
import 'package:finzoo/features/home/presentation/practice/practice_tasks.dart';
import 'package:finzoo/features/home/presentation/period_results_page.dart';
import 'package:finzoo/features/home/presentation/widgets/savings_dialog.dart';

import 'support/ui_shot_capture.dart';

class _MemStore extends PlayerProfileStore {
  PlayerProfile? _p;

  @override
  Future<PlayerProfile> load() async => _p ?? PlayerProfile.fresh();

  @override
  Future<void> save(PlayerProfile profile) async => _p = profile;
}

GameController _ctrl({
  PeriodPhase phase = PeriodPhase.playing,
  bool taskDone = false,
  String name = 'Магомед',
}) {
  return GameController(
    profile: PlayerProfile.fresh().copyWith(
      name: name,
      age: 9,
      onboardingDone: true,
      goalTitle: 'Велосипед',
      goalPrice: 2000,
      availableBalance: 280,
      savedBalance: 120,
      periodIndex: 1,
      periodPhase: phase,
      periodIncomeGranted: true,
      periodIncomeAmount: EconomyRules.periodIncome,
      periodIncomeLabel: EconomyRules.periodIncomeLabel,
      plan: const BudgetPlan(necessary: 180, wants: 100, savings: 80),
      spentNecessary: 50,
      spentWants: 0,
      factSavings: 40,
      periodTaskDone: taskDone,
      satiety: 62,
      mood: 74,
      streakDays: 3,
    ),
    store: _MemStore(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final out = Directory('build/ui_shots')..createSync(recursive: true);

  Future<void> shot(WidgetTester tester, String name) async {
    await captureUiShot(
      tester,
      path: '${out.path}/$name.png',
      settlePumps: 12,
    );
  }

  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    await tester.pumpWidget(
      RepaintBoundary(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: page,
        ),
      ),
    );
  }

  // SVG-сцены (улица/дом) снимаем с симулятора — здесь только текстовые экраны.

  testWidgets('budget', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpPage(
      tester,
      BudgetPlanPage(
        controller: _ctrl(phase: PeriodPhase.planning),
        onConfirmed: () {},
      ),
    );
    await shot(tester, 'budget');
  });

  testWidgets('task', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpPage(
      tester,
      FinancialTaskPage(controller: _ctrl(), onDone: () {}),
    );
    await shot(tester, 'task');
  });

  testWidgets('results', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpPage(
      tester,
      PeriodResultsPage(
        controller: _ctrl(phase: PeriodPhase.results),
        onNextPeriod: () {},
      ),
    );
    await shot(tester, 'results');
  });

  testWidgets('savings dialog', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final c = _ctrl();
    await pumpPage(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => showSavingsDialog(context, c),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await shot(tester, 'savings');
  });

  testWidgets('practice hub and tasks', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final c = _ctrl();
    await pumpPage(tester, GamesPage(controller: c, onBack: () {}));
    await shot(tester, 'practice_hub');
    for (final item in PracticeCatalog.all) {
      await pumpPage(
        tester,
        buildPracticeTask(item: item, controller: c, onDone: () {}),
      );
      await shot(tester, item.id);
    }
  });

  testWidgets('book pages 1 2 4 5 last', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final total = BookContent.flatPageCount;
    final shots = <int, String>{
      0: 'sim_book_p1',
      1: 'sim_book_p2',
      3: 'sim_book_p4',
      4: 'sim_book_p5',
      total - 1: 'sim_book_plast',
    };
    for (final e in shots.entries) {
      await pumpPage(
        tester,
        BookPage(startPage: e.key, animationsEnabled: false),
      );
      await shot(tester, e.value);
    }
  });
}
