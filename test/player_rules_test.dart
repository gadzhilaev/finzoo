import 'package:flutter_test/flutter_test.dart';
import 'package:finzoo/core/profile/budget_plan.dart';
import 'package:finzoo/core/profile/economy.dart';
import 'package:finzoo/core/profile/game_controller.dart';
import 'package:finzoo/core/profile/house_catalog.dart';
import 'package:finzoo/core/profile/player_profile.dart';
import 'package:finzoo/core/profile/player_profile_store.dart';
import 'package:finzoo/core/profile/player_rules.dart';

void main() {
  group('PlayerRules.streak', () {
    test('первый заход — 1 день, без начисления денег', () {
      final now = DateTime(2026, 9, 19, 10);
      final next = PlayerRules.applyStreak(PlayerProfile.fresh(), now);
      expect(next.streakDays, 1);
      expect(next.lastOpenDay, '2026-09-19');
      expect(PlayerRules.streakLabel(1), 'Начни серию');
      expect(next.availableBalance, 0);
    });

    test('подпись серии только со 2-го дня', () {
      expect(PlayerRules.streakLabel(0), 'Начни серию');
      expect(PlayerRules.streakLabel(2), '2 дня подряд');
      expect(PlayerRules.streakLabel(5), '5 дней подряд');
    });

    test('заход на следующий день увеличивает стрик без бонуса', () {
      final base = PlayerProfile.fresh().copyWith(
        streakDays: 3,
        lastOpenDay: '2026-09-18',
        availableBalance: 100,
      );
      final next = PlayerRules.applyStreak(base, DateTime(2026, 9, 19, 9));
      expect(next.streakDays, 4);
      expect(next.availableBalance, 100);
    });

    test('пропуск дня сбрасывает стрик', () {
      final base = PlayerProfile.fresh().copyWith(
        streakDays: 5,
        lastOpenDay: '2026-09-16',
      );
      final next = PlayerRules.applyStreak(base, DateTime(2026, 9, 19));
      expect(next.streakDays, 1);
      expect(PlayerRules.streakLabel(next.streakDays), 'Начни серию');
    });
  });

  group('PlayerRules.stats', () {
    test('сытость и настроение падают со временем', () {
      final base = PlayerProfile.fresh().copyWith(
        satiety: 80,
        mood: 70,
        lastStatsAt: DateTime(2026, 9, 19, 8).toIso8601String(),
      );
      final next = PlayerRules.applyStatsDecay(base, DateTime(2026, 9, 19, 12));
      expect(next.satiety, lessThan(80));
      expect(next.mood, lessThan(70));
    });
  });

  group('Economy', () {
    test('один доход периода меньше суммы всех товаров', () {
      expect(EconomyRules.periodIncome, 420);
      expect(ShopCatalog.totalOneOfEach, greaterThan(EconomyRules.periodIncome));
    });
  });

  group('Period cycle', () {
    test('онбординг даёт один доход и фазу планирования', () async {
      final c = GameController(
        profile: PlayerProfile.fresh(),
        store: _MemoryStore(),
      );
      await c.completeOnboarding(
        name: 'Тест',
        age: 10,
        goalTitle: 'Велосипед',
        goalPrice: 2000,
        goalImageAsset: '',
      );
      expect(c.profile.availableBalance, EconomyRules.periodIncome);
      expect(c.profile.periodIncomeGranted, isTrue);
      expect(c.profile.periodPhase, PeriodPhase.planning);
      expect(c.profile.periodIndex, 1);
    });

    test('повторный ответ на задание не даёт вторую награду', () async {
      final c = await _playingController();
      final before = c.profile.availableBalance;
      final r1 = await c.answerPeriodTask('food_first');
      expect(r1?.rewardGranted, isTrue);
      expect(r1?.rewardAmount, 0);
      expect(c.profile.availableBalance, before);
      final mid = c.profile.availableBalance;
      expect(await c.answerPeriodTask('ice_first'), isNull);
      expect(c.profile.availableBalance, mid);
    });

    test('план не списывает деньги; покупка списывает', () async {
      final c = await _playingController();
      final before = c.profile.availableBalance;
      expect(
        await c.confirmBudgetPlan(
          const BudgetPlan(necessary: 200, wants: 100, savings: 50),
        ),
        isFalse,
      );
      expect(c.profile.availableBalance, before);
      expect(
        await c.buyHouseItem(category: HouseItemCategory.kitchen, index: 0),
        isTrue,
      );
      expect(
        c.profile.availableBalance,
        before - ShopCatalog.kitchenPrices[0],
      );
      expect(c.profile.spentNecessary, ShopCatalog.kitchenPrices[0]);
    });

    test('нельзя купить всё сразу и уйти в минус', () async {
      final c = await _playingController();
      var bought = 0;
      for (var i = 0; i < HouseCatalog.kitchenCount; i++) {
        if (await c.buyHouseItem(
          category: HouseItemCategory.kitchen,
          index: i,
        )) {
          bought++;
        }
      }
      for (var i = 0; i < HouseCatalog.clothesCount; i++) {
        if (await c.buyHouseItem(
          category: HouseItemCategory.clothes,
          index: i,
        )) {
          bought++;
        }
      }
      for (var i = 0; i < HouseCatalog.showerCount; i++) {
        if (await c.buyHouseItem(
          category: HouseItemCategory.shower,
          index: i,
        )) {
          bought++;
        }
      }
      expect(bought, lessThan(20));
      expect(c.profile.availableBalance, greaterThanOrEqualTo(0));
    });

    test('накопления: проверка баланса и снятие', () async {
      final c = await _playingController();
      final fail = await c.saveTowardGoal(9999);
      expect(fail.ok, isFalse);

      final ok = await c.saveTowardGoal(100);
      expect(ok.ok, isTrue);
      expect(c.profile.savedBalance, 100);
      expect(c.profile.factSavings, 100);

      final back = await c.withdrawFromSavings(40);
      expect(back.ok, isTrue);
      expect(c.profile.savedBalance, 60);
    });

    test('полная цель получается и освобождает выбор следующей', () async {
      final c = await _playingController(balance: 300);
      c.profile = c.profile.copyWith(
        goalTitle: 'Наушники',
        goalPrice: 100,
        goalImageAsset: 'assets/images/goals/headphones.png',
      );
      expect((await c.saveTowardGoal(100)).ok, isTrue);
      expect(c.profile.isGoalComplete, isTrue);

      final claimed = await c.claimCompletedGoal();
      expect(claimed.ok, isTrue);
      expect(c.profile.goalTitle, isEmpty);
      expect(c.profile.savedBalance, 0);
      expect(c.profile.completedGoalTitles, contains('Наушники'));

      await c.chooseGoal(
        title: 'Удочка',
        price: 400,
        imageAsset: 'assets/images/goals/fishing.png',
      );
      expect(c.profile.goalTitle, 'Удочка');
      expect(c.profile.goalPrice, 400);
    });

    test('конец периода и следующий: остаток + один новый доход', () async {
      final c = await _playingController();
      await c.buyHouseItem(category: HouseItemCategory.kitchen, index: 4);
      final leftover = c.profile.availableBalance;
      expect(await c.finishPeriod(), isTrue);
      expect(c.profile.periodPhase, PeriodPhase.results);
      expect(c.profile.lastPeriodSummary.isNotEmpty, isTrue);

      expect(await c.startNextPeriod(), isTrue);
      expect(c.profile.periodIndex, 2);
      expect(c.profile.periodPhase, PeriodPhase.planning);
      expect(
        c.profile.availableBalance,
        leftover + EconomyRules.periodIncome,
      );
      expect(c.profile.periodIncomeGranted, isTrue);
      expect(c.profile.plan, isNull);
      expect(c.profile.periodTaskDone, isFalse);
      expect(c.profile.periodHistory, hasLength(1));
    });

    test('демо-профиль открывает пятый день и все практики в истории', () async {
      final c = GameController(profile: PlayerProfile.fresh(), store: _MemoryStore());
      await c.loadDemoProfile();
      expect(c.profile.onboardingDone, isTrue);
      expect(c.profile.periodIndex, 5);
      expect(c.profile.growthStage, PetGrowthStage.confident);
      expect(c.profile.periodHistory, isNotEmpty);
      expect(c.profile.parkCompletedIds, hasLength(6));
    });

    test('сохранение профиля переживает перезапуск', () async {
      final store = _MemoryStore();
      final c = GameController(profile: PlayerProfile.fresh(), store: store);
      await c.completeOnboarding(
        name: 'Аня',
        age: 9,
        goalTitle: 'Лодка',
        goalPrice: 3000,
        goalImageAsset: 'x',
      );
      await c.confirmBudgetPlan(
        const BudgetPlan(necessary: 180, wants: 100, savings: 80),
      );
      await c.saveTowardGoal(50);

      final loaded = await store.load();
      expect(loaded.name, 'Аня');
      expect(loaded.periodPhase, PeriodPhase.playing);
      expect(loaded.plan?.necessary, 180);
      expect(loaded.savedBalance, 50);
      expect(loaded.factSavings, 50);
      expect(loaded.periodIncomeGranted, isTrue);
    });

    test('миграция старого профиля без второго дохода', () async {
      final store = _MemoryStore();
      await store.save(
        PlayerProfile.fresh().copyWith(
          onboardingDone: true,
          availableBalance: 950,
          name: 'Старый',
          goalTitle: 'Мяч',
          goalPrice: 500,
        ),
      );
      final c = GameController(
        profile: await store.load(),
        store: store,
      );
      await c.onAppOpen();
      expect(c.profile.periodIndex, 1);
      expect(c.profile.availableBalance, 950);
      expect(c.profile.periodIncomeGranted, isTrue);
    });
  });

  group('House inventory', () {
    test('еду можно купить несколько порций в playing', () async {
      final c = await _playingController(balance: 400);
      expect(
        await c.buyHouseItem(
          category: HouseItemCategory.kitchen,
          index: 0,
          quantity: 3,
        ),
        isTrue,
      );
      expect(c.profile.inventoryQty('k0'), 3);
      expect(
        c.profile.availableBalance,
        400 - ShopCatalog.kitchenPrices[0] * 3,
      );
    });

    test('одежду только один раз', () async {
      final c = await _playingController(balance: 500);
      expect(
        await c.buyHouseItem(category: HouseItemCategory.clothes, index: 1),
        isTrue,
      );
      expect(
        await c.buyHouseItem(category: HouseItemCategory.clothes, index: 1),
        isFalse,
      );
    });

    test('без денег покупка не проходит', () async {
      final c = await _playingController(balance: 5);
      expect(
        await c.buyHouseItem(category: HouseItemCategory.shower, index: 0),
        isFalse,
      );
    });

    test('применение еды повышает сытость', () async {
      final c = await _playingController();
      c.profile = c.profile.copyWith(
        satiety: 70,
        inventory: const {'k0': 2},
      );
      expect(await c.useKitchenItem(0), isTrue);
      expect(c.profile.inventoryQty('k0'), 1);
      expect(
        c.profile.satiety,
        70 + ShopCatalog.item(HouseItemCategory.kitchen, 0).satietyDelta,
      );
    });

    test('при полной сытости еду нельзя', () async {
      final c = await _playingController();
      c.profile = c.profile.copyWith(
        satiety: 100,
        inventory: const {'k0': 1},
      );
      expect(await c.useKitchenItem(0), isFalse);
    });
  });
}

Future<GameController> _playingController({int? balance}) async {
  final c = GameController(
    profile: PlayerProfile.fresh(),
    store: _MemoryStore(),
  );
  await c.completeOnboarding(
    name: 'Тест',
    age: 10,
    goalTitle: 'Велосипед',
    goalPrice: 2000,
    goalImageAsset: '',
  );
  if (balance != null) {
    c.profile = c.profile.copyWith(availableBalance: balance);
  }
  expect(
    await c.confirmBudgetPlan(
      BudgetPlan(
        necessary: (c.profile.availableBalance * 0.4).round(),
        wants: (c.profile.availableBalance * 0.2).round(),
        savings: (c.profile.availableBalance * 0.2).round(),
      ),
    ),
    isTrue,
  );
  return c;
}

class _MemoryStore extends PlayerProfileStore {
  PlayerProfile? _saved;

  @override
  Future<PlayerProfile> load() async {
    final raw = _saved;
    if (raw == null) return PlayerProfile.fresh();
    // Как после перезапуска: через JSON.
    return PlayerProfile.fromJson(raw.toJson());
  }

  @override
  Future<void> save(PlayerProfile profile) async {
    _saved = profile;
  }
}
