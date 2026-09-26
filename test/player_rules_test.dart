import 'package:flutter_test/flutter_test.dart';
import 'package:finzoo/core/profile/player_profile.dart';
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
}
