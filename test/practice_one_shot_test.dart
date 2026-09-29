import 'dart:io';

import 'package:finzoo/core/profile/budget_plan.dart';
import 'package:finzoo/core/profile/economy.dart';
import 'package:finzoo/core/profile/game_controller.dart';
import 'package:finzoo/core/profile/player_profile.dart';
import 'package:finzoo/core/profile/player_profile_store.dart';
import 'package:finzoo/features/home/presentation/practice/practice_catalog.dart';
import 'package:finzoo/features/home/presentation/practice/practice_tasks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ui_shot_capture.dart';

/// Один кадр за прогон: --dart-define=SHOT_ID=practice_lunch
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const id = String.fromEnvironment('SHOT_ID', defaultValue: 'practice_lunch');

  testWidgets('shot $id', (tester) async {
    final out = Directory('build/ui_shots')..createSync(recursive: true);
    final c = GameController(
      profile: PlayerProfile.fresh().copyWith(
        name: 'Demo',
        age: 9,
        onboardingDone: true,
        availableBalance: 280,
        savedBalance: 120,
        periodIncomeGranted: true,
        periodIncomeAmount: EconomyRules.periodIncome,
        plan: const BudgetPlan(necessary: 180, wants: 100, savings: 80),
      ),
      store: _Mem(),
    );
    final item = PracticeCatalog.byId(id)!;
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      RepaintBoundary(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: buildPracticeTask(item: item, controller: c, onDone: () {}),
        ),
      ),
    );
    final file = await captureUiShot(
      tester,
      path: '${out.path}/$id.png',
      pixelRatio: 1.5,
      settlePumps: 12,
    );
    expect(file.existsSync(), isTrue);
  });
}

class _Mem extends PlayerProfileStore {
  PlayerProfile? _p;
  @override
  Future<PlayerProfile> load() async => _p ?? PlayerProfile.fresh();
  @override
  Future<void> save(PlayerProfile profile) async => _p = profile;
}
