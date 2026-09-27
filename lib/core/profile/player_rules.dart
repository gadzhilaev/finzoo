import 'player_profile.dart';

/// Правила стрика и «жизни» белки (без авто-начислений валюты).
abstract final class PlayerRules {
  /// Сытость падает быстрее настроения.
  static const satietyDecayPerHour = 2.5;
  static const moodDecayPerHour = 1.2;

  static String dayKey(DateTime dt) {
    final local = dt.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '${local.year}-$m-$d';
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

  /// Стрик для UI; деньги не начисляет (доход — только за период).
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

    return profile.copyWith(streakDays: streak, lastOpenDay: today);
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

  static String streakLabel(int days) {
    if (days < 2) return 'Начни серию';
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

  /// Текст сравнения плана и факта (для сохранения в профиле).
  static String buildPeriodSummary({
    required int periodIndex,
    required int planNecessary,
    required int planWants,
    required int planSavings,
    required int spentNecessary,
    required int spentWants,
    required int factSavings,
    required int remainingBalance,
    int careUses = 0,
    double satiety = 50,
  }) {
    final verdict = periodVerdict(
      planNecessary: planNecessary,
      planWants: planWants,
      planSavings: planSavings,
      spentNecessary: spentNecessary,
      spentWants: spentWants,
      factSavings: factSavings,
      careUses: careUses,
      satiety: satiety,
    );
    return 'День $periodIndex. $verdict '
        'Остаток $remainingBalance ₽ переносится дальше.';
  }

  /// Один короткий вывод для экрана итогов (без повтора цифр плана/факта).
  static String periodVerdict({
    required int planNecessary,
    required int planWants,
    required int planSavings,
    required int spentNecessary,
    required int spentWants,
    required int factSavings,
    int careUses = 0,
    double satiety = 50,
  }) {
    final totalActions = spentNecessary + spentWants + factSavings + careUses;
    final overNec = planNecessary > 0 && spentNecessary > planNecessary;
    final overWant = planWants > 0 && spentWants > planWants;
    final metNeedByBuy = spentNecessary > 0;
    final metNeedByStock = careUses > 0;
    final hungry = satiety < 40;

    if (totalActions == 0) {
      return 'Сегодня вы почти ничего не делали — это нормально. '
          'Можно просто отдохнуть и начать новый день.';
    }
    if (overNec || overWant) {
      return 'План по тратам превышен — завтра '
          'оставь больше на нужное или откажись от лишнего.';
    }
    if (hungry && !metNeedByBuy && !metNeedByStock) {
      return 'Finzo всё ещё голоден. Завтра не забудь про еду или запасы.';
    }
    if (metNeedByStock && spentNecessary == 0) {
      return 'Finzo поел из запасов — умный ход! '
          'Так можно экономить карманные.';
    }
    if (metNeedByBuy || metNeedByStock) {
      if (factSavings >= planSavings && planSavings > 0) {
        return 'Нужное закрыто, и копилка пополнилась — хороший день.';
      }
      if (factSavings > 0) {
        return 'Нужное закрыто, и немного отложили — так тоже хорошо.';
      }
      return 'Нужное для Finzo закрыто. В копилку можно отложить в другой раз.';
    }
    if (factSavings > 0 && spentNecessary == 0 && careUses == 0) {
      return 'В копилку отложили, а про еду и уход сегодня не заботились. '
          'Завтра вспомни про нужное.';
    }
    if (spentWants > 0 && spentNecessary == 0 && careUses == 0) {
      return 'Были желания, а нужное для Finzo не закрыли. '
          'Завтра начни с еды или ухода.';
    }
    return 'День прошёл по-своему. Завтра можно сделать иначе.';
  }

  /// Рост зависит от серии финансовых решений, а не от номера дня.
  /// За закрытое нужное даём 2 очка, за план без превышения — 1,
  /// за регулярные накопления — ещё 1. Стадии: 0–5, 6–11, 12+.
  static int growthPointsForPeriod({
    required int planNecessary,
    required int planWants,
    required int planSavings,
    required int spentNecessary,
    required int spentWants,
    required int factSavings,
    required int careUses,
  }) {
    var points = 0;
    if (spentNecessary > 0 || careUses > 0) points += 2;
    final followsPlan =
        (planNecessary == 0 || spentNecessary <= planNecessary) &&
        (planWants == 0 || spentWants <= planWants);
    if (followsPlan) points += 1;
    if (factSavings > 0 && (planSavings == 0 || factSavings >= planSavings)) {
      points += 1;
    }
    return points;
  }
}
