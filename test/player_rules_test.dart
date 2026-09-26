import 'package:flutter_test/flutter_test.dart';
import 'package:finzoo/core/profile/game_controller.dart';
import 'package:finzoo/core/profile/house_catalog.dart';
import 'package:finzoo/core/profile/player_profile.dart';
import 'package:finzoo/core/profile/player_profile_store.dart';
import 'package:finzoo/core/profile/player_rules.dart';

void main() {
  group('PlayerRules.streak', () {
    test('первый заход — 1 день внутри, на UI ещё не серия', () {
      final now = DateTime(2026, 9, 19, 10);
      final next = PlayerRules.applyStreak(PlayerProfile.fresh(), now);
      expect(next.streakDays, 1);
      expect(next.lastOpenDay, '2026-09-19');
      expect(PlayerRules.streakLabel(1), 'Начни серию');
    });

    test('подпись серии только со 2-го дня', () {
      expect(PlayerRules.streakLabel(0), 'Начни серию');
      expect(PlayerRules.streakLabel(2), '2 дня подряд');
      expect(PlayerRules.streakLabel(5), '5 дней подряд');
    });

    test('заход на следующий день увеличивает стрик', () {
      final base = PlayerProfile.fresh().copyWith(
        streakDays: 3,
        lastOpenDay: '2026-09-18',
        availableBalance: 100,
      );
      final next = PlayerRules.applyStreak(base, DateTime(2026, 9, 19, 9));
      expect(next.streakDays, 4);
      expect(next.availableBalance, 100 + PlayerRules.dailyLoginBonus);
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

  group('PlayerRules.allowance', () {
    test('родители кладут карманные раз в неделю', () {
      final base = PlayerProfile.fresh().copyWith(
        onboardingDone: true,
        availableBalance: 100,
        lastAllowanceWeek: '',
      );
      final next = PlayerRules.applyParentAllowance(
        base,
        DateTime(2026, 9, 19),
      );
      expect(next.availableBalance, 100 + PlayerRules.weeklyAllowance);
      expect(next.lastAllowanceWeek.isNotEmpty, isTrue);
    });
  });

  group('House inventory buy', () {
    test('еду можно купить сразу несколько порций', () async {
      final c = GameController(
        profile: PlayerProfile.fresh().copyWith(availableBalance: 100),
        store: _MemoryStore(),
      );
      expect(
        await c.buyHouseItem(
          category: HouseItemCategory.kitchen,
          index: 0,
          quantity: 3,
        ),
        isTrue,
      );
      expect(c.profile.inventoryQty('k0'), 3);
      expect(c.profile.availableBalance, 70);
    });

    test('одежду можно купить только один раз', () async {
      final c = GameController(
        profile: PlayerProfile.fresh().copyWith(availableBalance: 100),
        store: _MemoryStore(),
      );
      expect(
        await c.buyHouseItem(category: HouseItemCategory.clothes, index: 1),
        isTrue,
      );
      expect(c.profile.inventoryQty('c1'), 1);
      expect(
        await c.buyHouseItem(category: HouseItemCategory.clothes, index: 1),
        isFalse,
      );
      expect(c.profile.inventoryQty('c1'), 1);
      expect(c.profile.availableBalance, 90);
    });

    test('без денег покупка не проходит', () async {
      final c = GameController(
        profile: PlayerProfile.fresh().copyWith(availableBalance: 5),
        store: _MemoryStore(),
      );
      expect(
        await c.buyHouseItem(category: HouseItemCategory.shower, index: 0),
        isFalse,
      );
      expect(c.profile.inventoryQty('s0'), 0);
    });

    test('применение еды повышает сытость и списывает порцию', () async {
      final c = GameController(
        profile: PlayerProfile.fresh().copyWith(
          availableBalance: 50,
          satiety: 70,
          inventory: const {'k0': 2},
        ),
        store: _MemoryStore(),
      );
      expect(await c.useKitchenItem(0), isTrue);
      expect(c.profile.inventoryQty('k0'), 1);
      expect(c.profile.satiety, 70 + HouseCatalog.foodSatietyBoost);
    });

    test('при полной сытости еду применить нельзя', () async {
      final c = GameController(
        profile: PlayerProfile.fresh().copyWith(
          satiety: 100,
          inventory: const {'k0': 1},
        ),
        store: _MemoryStore(),
      );
      expect(c.isFullyFed, isTrue);
      expect(await c.useKitchenItem(0), isFalse);
      expect(c.profile.inventoryQty('k0'), 1);
    });
  });
}

class _MemoryStore extends PlayerProfileStore {
  PlayerProfile? _saved;

  @override
  Future<PlayerProfile> load() async => _saved ?? PlayerProfile.fresh();

  @override
  Future<void> save(PlayerProfile profile) async {
    _saved = profile;
  }
}
