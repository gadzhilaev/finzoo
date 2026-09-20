import 'player_profile.dart';

/// Правила экономики и «жизни» белки.
abstract final class PlayerRules {
  /// Первый подарок от родителей после регистрации.
  static const initialParentGift = 650;

  /// Карманные раз в неделю.
  static const weeklyAllowance = 300;

  /// Бонус за ежедневный заход (кроме первого дня стрика).
  static const dailyLoginBonus = 25;

  /// Награда за «Задание дня».
  static const dailyTaskReward = 50;

  /// Сытость падает быстрее настроения.
  static const satietyDecayPerHour = 2.5;
  static const moodDecayPerHour = 1.2;

  static String dayKey(DateTime dt) {
    final local = dt.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '${local.year}-$m-$d';
  }

  static String weekKey(DateTime dt) {
    final local = dt.toLocal();
    // Простая неделя: год + номер недели ISO-ish через days since epoch.
    final days = local.difference(DateTime(local.year)).inDays;
    final week = (days / 7).floor() + 1;
    return '${local.year}-W${week.toString().padLeft(2, '0')}';
  }

  static DateTime? parseDay(String key) {
    if (key.isEmpty) return null;
    final parts = key.split('-');
    if (parts.length != 3) return null;
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static PlayerProfile applyStreak(PlayerProfile profile, DateTime now) {
    final today = dayKey(now);
    if (profile.lastOpenDay == today) return profile;

    final last = parseDay(profile.lastOpenDay);
    final todayDate = DateTime(now.year, now.month, now.day);

    var streak = 1;
    if (last != null) {
      final diff = todayDate.difference(last).inDays;
      if (diff == 1) {
        streak = profile.streakDays + 1;
      } else if (diff == 0) {
        streak = profile.streakDays;
      } else {
        streak = 1;
      }
    }

    var balance = profile.availableBalance;
    // Бонус за продолжение стрика со 2-го дня.
    if (streak > 1 && profile.lastOpenDay.isNotEmpty) {
      balance += dailyLoginBonus;
    }

    return profile.copyWith(
      streakDays: streak,
      lastOpenDay: today,
      availableBalance: balance,
    );
  }

  static PlayerProfile applyStatsDecay(PlayerProfile profile, DateTime now) {
    final last = DateTime.tryParse(profile.lastStatsAt) ?? now;
    final hours = now.difference(last).inMinutes / 60.0;
    if (hours <= 0) return profile;

    final satiety = (profile.satiety - hours * satietyDecayPerHour).clamp(
      5.0,
      100.0,
    );
    final mood = (profile.mood - hours * moodDecayPerHour).clamp(8.0, 100.0);

    return profile.copyWith(
      satiety: satiety,
      mood: mood,
      lastStatsAt: now.toIso8601String(),
    );
  }

  static PlayerProfile applyParentAllowance(
    PlayerProfile profile,
    DateTime now,
  ) {
    if (!profile.onboardingDone) return profile;
    final week = weekKey(now);
    if (profile.lastAllowanceWeek == week) return profile;

    return profile.copyWith(
      lastAllowanceWeek: week,
      availableBalance: profile.availableBalance + weeklyAllowance,
    );
  }

  static String streakLabel(int days) {
    if (days <= 0) return 'Начни серию';
    return '$days ${_dayWord(days)} подряд';
  }

  static String _dayWord(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return 'день';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'дня';
    }
    return 'дней';
  }
}
