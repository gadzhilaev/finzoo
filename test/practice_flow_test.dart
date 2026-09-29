import 'package:finzoo/core/profile/economy.dart';
import 'package:finzoo/core/profile/game_controller.dart';
import 'package:finzoo/core/profile/player_profile.dart';
import 'package:finzoo/core/profile/player_profile_store.dart';
import 'package:finzoo/features/home/presentation/practice/practice_catalog.dart';
import 'package:finzoo/features/home/presentation/practice/practice_content.dart';
import 'package:finzoo/features/home/presentation/practice/practice_tasks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Mem extends PlayerProfileStore {
  PlayerProfile? _p;
  @override
  Future<PlayerProfile> load() async => _p ?? PlayerProfile.fresh();
  @override
  Future<void> save(PlayerProfile profile) async => _p = profile;
}

GameController _ctrl({List<String> done = const []}) {
  return GameController(
    profile: PlayerProfile.fresh().copyWith(
      name: 'Test',
      age: 9,
      onboardingDone: true,
      availableBalance: 280,
      savedBalance: 120,
      periodIncomeGranted: true,
      periodIncomeAmount: EconomyRules.periodIncome,
      parkCompletedIds: done,
    ),
    store: _Mem(),
  );
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(393, 852));
  await tester.pumpWidget(MaterialApp(home: child));
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 40));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('old park ids do not count as new practice', () {
    final done = PracticeCatalog.completedIds(['park_bike', 'budget_split']);
    expect(done, isEmpty);
    expect(PracticeCatalog.resolveOpenId('park_bike'), PracticeCatalog.dayPlan);
  });

  testWidgets('lunch: first finish awards taskReward once', (tester) async {
    final c = _ctrl();
    final bal = c.profile.availableBalance;
    await _pump(
      tester,
      LunchPracticePage(controller: c, onDone: () {}),
    );
    await tester.tap(find.text('Суп'));
    await tester.pump();
    await tester.tap(find.text('Чай'));
    await tester.pump();
    await tester.tap(find.text('Подать обед'));
    await tester.pump();
    expect(find.textContaining('Потратил'), findsOneWidget);
    expect(c.profile.parkCompletedIds, contains(PracticeCatalog.lunch));
    expect(
      c.profile.availableBalance,
      bal + EconomyRules.taskReward,
    );
    // Учебные монеты задания не списываются — только разовая награда.
    expect(c.profile.periodTaskDone, isFalse);
  });

  testWidgets('day plan leftover awards taskReward', (tester) async {
    final c = _ctrl();
    await _pump(
      tester,
      DayPlanPracticePage(controller: c, onDone: () {}),
    );
    await tester.tap(find.text('Подтвердить план'));
    await tester.pump();
    expect(find.textContaining('Не распределено'), findsOneWidget);
    expect(
      c.profile.availableBalance,
      280 + EconomyRules.taskReward,
    );
  });

  testWidgets('receipt: wrong pay can be fixed', (tester) async {
    final c = _ctrl();
    await _pump(
      tester,
      ReceiptPracticePage(controller: c, onDone: () {}),
    );
    for (final g in PracticeContent.receiptGear.where((e) => e.required)) {
      await tester.tap(find.text(g.title));
      await tester.pump();
    }
    await tester.tap(find.text('К чеку'));
    await tester.pump();
    await tester.tap(find.textContaining('Чипсы'));
    await tester.pump();
    await tester.tap(find.text('К оплате'));
    await tester.pump();
    await tester.tap(find.text('Оплатить'));
    await tester.pump();
    expect(find.textContaining('Нужно ровно'), findsOneWidget);
    expect(find.text('Исправить оплату'), findsOneWidget);
  });

  testWidgets('plan change shows goal impact before confirm', (tester) async {
    final c = _ctrl();
    await _pump(
      tester,
      PlanChangePracticePage(controller: c, onDone: () {}),
    );
    expect(find.textContaining('до цели после'), findsOneWidget);
    await tester.tap(find.text('Подтвердить'));
    await tester.pump();
    expect(find.textContaining('Снятие на необходимое'), findsOneWidget);
  });
}
