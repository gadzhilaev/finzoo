import 'budget_plan.dart';

/// Стадии роста Finzo открываются по числу прожитых игровых дней.
enum PetGrowthStage { little, growing, confident }

extension PetGrowthStageText on PetGrowthStage {
  String get title => switch (this) {
        PetGrowthStage.little => 'Малыш Finzo',
        PetGrowthStage.growing => 'Растущий Finzo',
        PetGrowthStage.confident => 'Самостоятельный Finzo',
      };

  String get description => switch (this) {
        PetGrowthStage.little => 'Учится заботиться о себе вместе с тобой.',
        PetGrowthStage.growing => 'Уже умеет планировать день и копить.',
        PetGrowthStage.confident => 'Уверенно делает финансовый выбор.',
      };
}

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
    this.inventory = const {},
    this.periodIndex = 0,
    this.periodPhase = PeriodPhase.planning,
    this.periodIncomeAmount = 0,
    this.periodIncomeLabel = '',
    this.periodIncomeGranted = false,
    this.periodOpeningBalance = 0,
    this.plan,
    this.spentNecessary = 0,
    this.spentWants = 0,
    this.factSavings = 0,
    this.periodTaskDone = false,
    this.periodTaskRewardGranted = false,
    this.lastPeriodSummary = '',
    this.periodHistory = const [],
    this.dayEndIntroShown = false,
    this.periodCareUses = 0,
    this.parkCompletedIds = const [],
    this.periodPracticeCompletedIds = const [],
    this.boostedItemKeys = const [],
    this.seenMessageIds = const [],
    this.equippedBodyKey,
    this.equippedHeadKey,
    this.practiceTipShown = false,
    this.completedGoalTitles = const [],
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
        inventory: const {},
      );

  final String name;
  final int age;
  final bool onboardingDone;

  /// Можно тратить.
  final int availableBalance;

  /// Отложено на цель.
  final int savedBalance;

  final String goalTitle;
  final int goalPrice;
  final String goalImageAsset;

  final int streakDays;
  final String lastOpenDay;
  final double satiety;
  final double mood;
  final String lastStatsAt;

  /// Устарело для начислений; оставлено для совместимости JSON.
  final String lastAllowanceWeek;
  final String dailyTaskDoneDay;

  final Map<String, int> inventory;

  /// Номер текущего периода (1…). 0 = ещё не начат.
  final int periodIndex;
  final PeriodPhase periodPhase;

  /// Доход текущего периода (для UI «вы получили»).
  final int periodIncomeAmount;
  final String periodIncomeLabel;
  final bool periodIncomeGranted;

  /// Доступный остаток до выдачи дохода нового игрового дня.
  final int periodOpeningBalance;

  /// Подтверждённый план (null до подтверждения).
  final BudgetPlan? plan;

  /// Факт трат периода по направлениям.
  final int spentNecessary;
  final int spentWants;
  final int factSavings;

  final bool periodTaskDone;
  final bool periodTaskRewardGranted;
  final String lastPeriodSummary;

  /// Короткие итоги завершённых игровых дней, последние сверху.
  final List<String> periodHistory;

  /// Показали ли объяснение «Закончить день».
  final bool dayEndIntroShown;

  /// Сколько раз за день применили еду/уход из запасов (не покупка).
  final int periodCareUses;

  /// Пройденные упражнения парка (можно повторять, прогресс хранится).
  final List<String> parkCompletedIds;

  /// Упражнения, закрытые в текущем игровом дне.
  /// Общая история остаётся в [parkCompletedIds], а этот список очищается
  /// при старте следующего периода.
  final List<String> periodPracticeCompletedIds;

  /// Одежда/уход, уже давшие бонус настроения (повторно не усиливают).
  final List<String> boostedItemKeys;

  /// Показанные подсказки на экране сообщений (без дублей).
  final List<String> seenMessageIds;

  /// Надетая одежда на туловище (`c0`…), null = снято.
  final String? equippedBodyKey;

  /// Надетый головной убор (`c3`/`c4`/`c6`), null = снято.
  final String? equippedHeadKey;

  /// Показали краткий тизер про учебные монеты на экране практики.
  final bool practiceTipShown;

  /// Уже полученные цели. Нужны для истории и взрослого экрана.
  final List<String> completedGoalTitles;

  int inventoryQty(String key) => inventory[key] ?? 0;

  bool isEquipped(String key) =>
      equippedBodyKey == key || equippedHeadKey == key;

  /// Карманные, полученные сегодня (0 если ещё не начислены).
  int get todayIncome =>
      periodIncomeGranted && periodIncomeAmount > 0 ? periodIncomeAmount : 0;

  /// Остаток со вчера в доступных (накопления не входят).
  int get carryoverAvailable => periodOpeningBalance;

  bool get isGoalComplete =>
      goalPrice > 0 && savedBalance >= goalPrice && goalTitle.isNotEmpty;

  PetGrowthStage get growthStage {
    if (periodIndex >= 5) return PetGrowthStage.confident;
    if (periodIndex >= 3) return PetGrowthStage.growing;
    return PetGrowthStage.little;
  }

  /// Визуальный рост сохраняет одну и ту же композицию одежды и аксессуаров.
  double get growthVisualScale => switch (growthStage) {
        PetGrowthStage.little => 0.82,
        PetGrowthStage.growing => 0.91,
        PetGrowthStage.confident => 1.0,
      };

  /// Всё, что можно распределить в плане (без копилки).
  int get distributableBudget => availableBalance;

  int get remainingToGoal => (goalPrice - savedBalance).clamp(0, goalPrice);

  double get goalProgress {
    if (goalPrice <= 0) return 0;
    return (savedBalance / goalPrice).clamp(0.0, 1.0);
  }

  /// Подпись прогресса: при малой сумме не показывать округлённые «0%».
  String get goalProgressLabel {
    if (savedBalance <= 0) return '0%';
    if (goalPrice <= 0) return '—';
    final pct = goalProgress * 100;
    if (pct > 0 && pct < 1) return 'меньше 1%';
    return '${pct.round()}%';
  }

  bool get needsBudgetPlan =>
      onboardingDone && periodPhase == PeriodPhase.planning;

  bool get canPlayPeriod =>
      onboardingDone && periodPhase == PeriodPhase.playing;

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
    Map<String, int>? inventory,
    int? periodIndex,
    PeriodPhase? periodPhase,
    int? periodIncomeAmount,
    String? periodIncomeLabel,
    bool? periodIncomeGranted,
    int? periodOpeningBalance,
    BudgetPlan? plan,
    bool clearPlan = false,
    int? spentNecessary,
    int? spentWants,
    int? factSavings,
    bool? periodTaskDone,
    bool? periodTaskRewardGranted,
    String? lastPeriodSummary,
    List<String>? periodHistory,
    bool? dayEndIntroShown,
    int? periodCareUses,
    List<String>? parkCompletedIds,
    List<String>? periodPracticeCompletedIds,
    List<String>? boostedItemKeys,
    List<String>? seenMessageIds,
    String? equippedBodyKey,
    String? equippedHeadKey,
    bool clearEquippedBody = false,
    bool clearEquippedHead = false,
    bool? practiceTipShown,
    List<String>? completedGoalTitles,
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
      inventory: inventory ?? this.inventory,
      periodIndex: periodIndex ?? this.periodIndex,
      periodPhase: periodPhase ?? this.periodPhase,
      periodIncomeAmount: periodIncomeAmount ?? this.periodIncomeAmount,
      periodIncomeLabel: periodIncomeLabel ?? this.periodIncomeLabel,
      periodIncomeGranted: periodIncomeGranted ?? this.periodIncomeGranted,
      periodOpeningBalance: periodOpeningBalance ?? this.periodOpeningBalance,
      plan: clearPlan ? null : (plan ?? this.plan),
      spentNecessary: spentNecessary ?? this.spentNecessary,
      spentWants: spentWants ?? this.spentWants,
      factSavings: factSavings ?? this.factSavings,
      periodTaskDone: periodTaskDone ?? this.periodTaskDone,
      periodTaskRewardGranted:
          periodTaskRewardGranted ?? this.periodTaskRewardGranted,
      lastPeriodSummary: lastPeriodSummary ?? this.lastPeriodSummary,
      periodHistory: periodHistory ?? this.periodHistory,
      dayEndIntroShown: dayEndIntroShown ?? this.dayEndIntroShown,
      periodCareUses: periodCareUses ?? this.periodCareUses,
      parkCompletedIds: parkCompletedIds ?? this.parkCompletedIds,
      periodPracticeCompletedIds:
          periodPracticeCompletedIds ?? this.periodPracticeCompletedIds,
      boostedItemKeys: boostedItemKeys ?? this.boostedItemKeys,
      seenMessageIds: seenMessageIds ?? this.seenMessageIds,
      equippedBodyKey:
          clearEquippedBody ? null : (equippedBodyKey ?? this.equippedBodyKey),
      equippedHeadKey:
          clearEquippedHead ? null : (equippedHeadKey ?? this.equippedHeadKey),
      practiceTipShown: practiceTipShown ?? this.practiceTipShown,
      completedGoalTitles: completedGoalTitles ?? this.completedGoalTitles,
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
        'inventory': inventory,
        'periodIndex': periodIndex,
        'periodPhase': periodPhaseToName(periodPhase),
        'periodIncomeAmount': periodIncomeAmount,
        'periodIncomeLabel': periodIncomeLabel,
        'periodIncomeGranted': periodIncomeGranted,
        'periodOpeningBalance': periodOpeningBalance,
        'plan': plan?.toJson(),
        'spentNecessary': spentNecessary,
        'spentWants': spentWants,
        'factSavings': factSavings,
        'periodTaskDone': periodTaskDone,
        'periodTaskRewardGranted': periodTaskRewardGranted,
        'lastPeriodSummary': lastPeriodSummary,
        'periodHistory': periodHistory,
        'dayEndIntroShown': dayEndIntroShown,
        'periodCareUses': periodCareUses,
        'parkCompletedIds': parkCompletedIds,
        'periodPracticeCompletedIds': periodPracticeCompletedIds,
        'boostedItemKeys': boostedItemKeys,
        'seenMessageIds': seenMessageIds,
        'equippedBodyKey': equippedBodyKey,
        'equippedHeadKey': equippedHeadKey,
        'practiceTipShown': practiceTipShown,
        'completedGoalTitles': completedGoalTitles,
      };

  factory PlayerProfile.fromJson(Map<String, Object?> json) {
    final rawInv = json['inventory'];
    final inventory = <String, int>{};
    if (rawInv is Map) {
      for (final e in rawInv.entries) {
        final v = e.value;
        final n = v is int ? v : (v is num ? v.toInt() : int.tryParse('$v'));
        if (n != null && n > 0) inventory['${e.key}'] = n;
      }
    }

    final planRaw = json['plan'];
    BudgetPlan? plan;
    if (planRaw is Map) {
      plan = BudgetPlan.fromJson(Map<String, Object?>.from(planRaw));
    }

    var periodIndex = (json['periodIndex'] as num?)?.toInt() ?? 0;
    var phase = periodPhaseFromName(json['periodPhase'] as String?);
    final onboardingDone = json['onboardingDone'] as bool? ?? false;

    // Миграция старых профилей без периодов.
    if (onboardingDone && periodIndex <= 0) {
      periodIndex = 1;
      phase = PeriodPhase.planning;
    }

    final rawPark = json['parkCompletedIds'];
    final parkIds = <String>[];
    if (rawPark is List) {
      for (final e in rawPark) {
        final s = '$e';
        if (s.isNotEmpty) parkIds.add(s);
      }
    }

    List<String> stringList(String key) {
      final raw = json[key];
      final out = <String>[];
      if (raw is List) {
        for (final e in raw) {
          final s = '$e';
          if (s.isNotEmpty) out.add(s);
        }
      }
      return out;
    }

    final periodPracticeIds = stringList('periodPracticeCompletedIds');

    return PlayerProfile(
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 10,
      onboardingDone: onboardingDone,
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
      inventory: inventory,
      periodIndex: periodIndex,
      periodPhase: phase,
      periodIncomeAmount: (json['periodIncomeAmount'] as num?)?.toInt() ?? 0,
      periodIncomeLabel: json['periodIncomeLabel'] as String? ?? '',
      periodIncomeGranted: json['periodIncomeGranted'] as bool? ?? false,
      periodOpeningBalance:
          (json['periodOpeningBalance'] as num?)?.toInt() ?? 0,
      plan: plan,
      spentNecessary: (json['spentNecessary'] as num?)?.toInt() ?? 0,
      spentWants: (json['spentWants'] as num?)?.toInt() ?? 0,
      factSavings: (json['factSavings'] as num?)?.toInt() ?? 0,
      periodTaskDone: json['periodTaskDone'] as bool? ?? false,
      periodTaskRewardGranted:
          json['periodTaskRewardGranted'] as bool? ?? false,
      lastPeriodSummary: json['lastPeriodSummary'] as String? ?? '',
      periodHistory: stringList('periodHistory'),
      dayEndIntroShown: json['dayEndIntroShown'] as bool? ?? false,
      periodCareUses: (json['periodCareUses'] as num?)?.toInt() ?? 0,
      parkCompletedIds: parkIds,
      // Профили до дневного прогресса показывают уже закрытые задания
      // завершёнными только в текущем дне; на следующем они начнутся заново.
      periodPracticeCompletedIds:
          periodPracticeIds.isNotEmpty ? periodPracticeIds : parkIds,
      boostedItemKeys: stringList('boostedItemKeys'),
      seenMessageIds: stringList('seenMessageIds'),
      equippedBodyKey: _nullableString(json['equippedBodyKey']),
      equippedHeadKey: _nullableString(json['equippedHeadKey']),
      practiceTipShown: json['practiceTipShown'] as bool? ?? false,
      completedGoalTitles: stringList('completedGoalTitles'),
    );
  }
}

String? _nullableString(Object? v) {
  if (v == null) return null;
  final s = '$v';
  return s.isEmpty ? null : s;
}
