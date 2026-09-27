/// Направление расхода в плане бюджета.
enum BudgetBucket { necessary, wants, savings }

extension BudgetBucketLabel on BudgetBucket {
  String get titleRu => switch (this) {
        BudgetBucket.necessary => 'Необходимое',
        BudgetBucket.wants => 'Желания',
        BudgetBucket.savings => 'Накопления',
      };
}

/// План на игровой период (не списывает деньги сам по себе).
class BudgetPlan {
  const BudgetPlan({
    required this.necessary,
    required this.wants,
    required this.savings,
  });

  final int necessary;
  final int wants;
  final int savings;

  int get total => necessary + wants + savings;

  BudgetPlan copyWith({int? necessary, int? wants, int? savings}) {
    return BudgetPlan(
      necessary: necessary ?? this.necessary,
      wants: wants ?? this.wants,
      savings: savings ?? this.savings,
    );
  }

  Map<String, Object?> toJson() => {
        'necessary': necessary,
        'wants': wants,
        'savings': savings,
      };

  factory BudgetPlan.fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return const BudgetPlan(necessary: 0, wants: 0, savings: 0);
    }
    return BudgetPlan(
      necessary: (json['necessary'] as num?)?.toInt() ?? 0,
      wants: (json['wants'] as num?)?.toInt() ?? 0,
      savings: (json['savings'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Фаза текущего игрового периода.
enum PeriodPhase {
  /// Нужно составить и подтвердить план.
  planning,

  /// План подтверждён — можно тратить и копить.
  playing,

  /// Показаны итоги; ждём старт следующего периода.
  results,
}

PeriodPhase periodPhaseFromName(String? raw) {
  return switch (raw) {
    'playing' => PeriodPhase.playing,
    'results' => PeriodPhase.results,
    _ => PeriodPhase.planning,
  };
}

String periodPhaseToName(PeriodPhase phase) => phase.name;
