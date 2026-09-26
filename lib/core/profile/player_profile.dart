/// Сохранённый профиль игрока Finzoo.
class PlayerProfile {
  const PlayerProfile({
    required this.name,
    required this.age,
    required this.onboardingDone,
    required this.availableBalance,
    required this.savedBalance,
    required this.goalTitle,
    required this.goalPrice,
    required this.goalImageAsset,
    required this.streakDays,
    required this.lastOpenDay,
    required this.satiety,
    required this.mood,
    required this.lastStatsAt,
    required this.lastAllowanceWeek,
    required this.dailyTaskDoneDay,
  });

  factory PlayerProfile.fresh() => PlayerProfile(
    name: '',
    age: 10,
    onboardingDone: false,
    availableBalance: 0,
    savedBalance: 0,
    goalTitle: '',
    goalPrice: 0,
    goalImageAsset: '',
    streakDays: 0,
    lastOpenDay: '',
    satiety: 80,
    mood: 70,
    lastStatsAt: DateTime.now().toIso8601String(),
    lastAllowanceWeek: '',
    dailyTaskDoneDay: '',
  );

  final String name;
  final int age;
  final bool onboardingDone;

  /// Карманные от родителей / задания — можно тратить.
  final int availableBalance;

  /// Уже отложено на цель.
  final int savedBalance;

  final String goalTitle;
  final int goalPrice;

  /// Картинка цели из `assets/images/goals/`.
  final String goalImageAsset;

  /// Дни подряд с заходом в приложение.
  final int streakDays;

  /// Последний день захода в формате `yyyy-MM-dd`.
  final String lastOpenDay;

  /// Сытость 0–100.
  final double satiety;

  /// Настроение 0–100.
  final double mood;

  final String lastStatsAt;

  /// Неделя последнего «карманных» от родителей `yyyy-Www`.
  final String lastAllowanceWeek;

  /// День, когда выполнено задание дня.
  final String dailyTaskDoneDay;

  int get remainingToGoal => (goalPrice - savedBalance).clamp(0, goalPrice);

  double get goalProgress {
    if (goalPrice <= 0) return 0;
    return (savedBalance / goalPrice).clamp(0.0, 1.0);
  }

  PlayerProfile copyWith({
    String? name,
    int? age,
    bool? onboardingDone,
    int? availableBalance,
    int? savedBalance,
    String? goalTitle,
    int? goalPrice,
    String? goalImageAsset,
    int? streakDays,
    String? lastOpenDay,
    double? satiety,
    double? mood,
    String? lastStatsAt,
    String? lastAllowanceWeek,
    String? dailyTaskDoneDay,
  }) {
    return PlayerProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      availableBalance: availableBalance ?? this.availableBalance,
      savedBalance: savedBalance ?? this.savedBalance,
      goalTitle: goalTitle ?? this.goalTitle,
      goalPrice: goalPrice ?? this.goalPrice,
      goalImageAsset: goalImageAsset ?? this.goalImageAsset,
      streakDays: streakDays ?? this.streakDays,
      lastOpenDay: lastOpenDay ?? this.lastOpenDay,
      satiety: satiety ?? this.satiety,
      mood: mood ?? this.mood,
      lastStatsAt: lastStatsAt ?? this.lastStatsAt,
      lastAllowanceWeek: lastAllowanceWeek ?? this.lastAllowanceWeek,
      dailyTaskDoneDay: dailyTaskDoneDay ?? this.dailyTaskDoneDay,
    );
  }

  Map<String, Object?> toJson() => {
    'name': name,
    'age': age,
    'onboardingDone': onboardingDone,
    'availableBalance': availableBalance,
    'savedBalance': savedBalance,
    'goalTitle': goalTitle,
    'goalPrice': goalPrice,
    'goalImageAsset': goalImageAsset,
    'streakDays': streakDays,
    'lastOpenDay': lastOpenDay,
    'satiety': satiety,
    'mood': mood,
    'lastStatsAt': lastStatsAt,
    'lastAllowanceWeek': lastAllowanceWeek,
    'dailyTaskDoneDay': dailyTaskDoneDay,
  };

  factory PlayerProfile.fromJson(Map<String, Object?> json) {
    return PlayerProfile(
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 10,
      onboardingDone: json['onboardingDone'] as bool? ?? false,
      availableBalance: json['availableBalance'] as int? ?? 0,
      savedBalance: json['savedBalance'] as int? ?? 0,
      goalTitle: json['goalTitle'] as String? ?? '',
      goalPrice: json['goalPrice'] as int? ?? 0,
      goalImageAsset: json['goalImageAsset'] as String? ?? '',
      streakDays: json['streakDays'] as int? ?? 0,
      lastOpenDay: json['lastOpenDay'] as String? ?? '',
      satiety: (json['satiety'] as num?)?.toDouble() ?? 80,
      mood: (json['mood'] as num?)?.toDouble() ?? 70,
      lastStatsAt:
          json['lastStatsAt'] as String? ?? DateTime.now().toIso8601String(),
      lastAllowanceWeek: json['lastAllowanceWeek'] as String? ?? '',
      dailyTaskDoneDay: json['dailyTaskDoneDay'] as String? ?? '',
    );
  }
}
