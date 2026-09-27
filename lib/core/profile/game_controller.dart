import 'package:flutter/foundation.dart';

import 'budget_plan.dart';
import 'economy.dart';
import 'financial_tasks.dart';
import 'house_catalog.dart';
import 'player_profile.dart';
import 'player_profile_store.dart';
import 'player_rules.dart';
import '../wardrobe/wardrobe_catalog.dart';

/// Результат надевания одежды.
class EquipClothesResult {
  const EquipClothesResult({
    required this.ok,
    this.moodGain = 0,
    this.firstBoost = false,
  });

  final bool ok;
  final double moodGain;
  final bool firstBoost;
}

/// Результат ответа на финансовое задание.
class TaskAnswerResult {
  const TaskAnswerResult({
    required this.correct,
    required this.explanation,
    required this.rewardGranted,
    required this.rewardAmount,
  });

  final bool correct;
  final String explanation;
  final bool rewardGranted;
  final int rewardAmount;
}

/// Результат перевода в накопления / снятия.
class SavingsMoveResult {
  const SavingsMoveResult({
    required this.ok,
    this.message = '',
    this.moved = 0,
  });

  final bool ok;
  final String message;
  final int moved;
}

/// Результат получения накопленной цели.
class GoalClaimResult {
  const GoalClaimResult({required this.ok, this.message = ''});

  final bool ok;
  final String message;
}

/// Живое состояние игрока: период, бюджет, покупки, накопления.
class GameController extends ChangeNotifier {
  GameController({
    required this.profile,
    PlayerProfileStore? store,
    DateTime Function()? now,
  }) : _store = store ?? PlayerProfileStore(),
       _now = now ?? DateTime.now;

  final PlayerProfileStore _store;
  final DateTime Function() _now;

  PlayerProfile profile;

  static Future<GameController> bootstrap() async {
    const shot = String.fromEnvironment('UI_SHOT');
    if (shot.startsWith('wardrobe')) {
      // Отдельная QA-сессия: не трогаем finzoo_player_profile_v1.
      return GameController(
        profile: wardrobeShotProfile(shot),
        store: _EphemeralProfileStore(),
      );
    }
    final store = PlayerProfileStore();
    final loaded = await store.load();
    final controller = GameController(profile: loaded, store: store);
    await controller.onAppOpen();
    return controller;
  }

  /// Профиль для `--dart-define=UI_SHOT=wardrobe_*` (экипировка / диалоги).
  @visibleForTesting
  static PlayerProfile wardrobeShotProfile(String shot) {
    final inv = <String, int>{
      for (var i = 0; i < 8; i++) 'c$i': 1,
    };
    var body = 'c0'; // свитер
    var head = 'c3'; // очки
    if (shot.contains('tee_bow') || shot.contains('tee+bow')) {
      body = 'c1';
      head = 'c4';
    } else if (shot.contains('suit_hat') || shot.contains('suit+hat')) {
      body = 'c7';
      head = 'c6';
    } else if (shot.contains('hoodie_hat')) {
      body = 'c5';
      head = 'c6';
    } else if (shot.contains('dress_bow')) {
      body = 'c2';
      head = 'c4';
    } else if (shot.contains('goggles_only')) {
      body = '';
      head = 'c3';
    } else if (shot.contains('none')) {
      body = '';
      head = '';
    }
    // dialog_* — вещь не надета, чтобы открыть «Купить?» / «Надеть?»
    final forDialog = shot.contains('dialog_');
    return PlayerProfile.fresh().copyWith(
      name: 'QA',
      age: 10,
      onboardingDone: true,
      availableBalance: forDialog && shot.contains('buy') ? 500 : 200,
      savedBalance: 50,
      goalTitle: 'Велосипед',
      goalPrice: 800,
      satiety: 90,
      mood: 80,
      periodIndex: 1,
      periodPhase: PeriodPhase.playing,
      periodIncomeGranted: true,
      periodIncomeAmount: EconomyRules.periodIncome,
      plan: const BudgetPlan(necessary: 100, wants: 200, savings: 50),
      inventory: inv,
      equippedBodyKey: forDialog ? null : (body.isEmpty ? null : body),
      equippedHeadKey: forDialog ? null : (head.isEmpty ? null : head),
      clearEquippedBody: forDialog || body.isEmpty,
      clearEquippedHead: forDialog || head.isEmpty,
      boostedItemKeys: const ['c0', 'c1', 'c3', 'c4', 'c6'],
    );
  }

  Future<void> _persist() async {
    await _store.save(profile);
    notifyListeners();
  }

  Future<void> onAppOpen() async {
    final now = _now();
    var next = PlayerRules.applyStatsDecay(profile, now);
    next = PlayerRules.applyStreak(next, now);
    next = _migrateGoalPrice(next);
    // Старые профили: баланс уже есть → помечаем доход выданным, без второго начисления.
    // Пустой баланс и флаг не выдан → один грант периода.
    if (next.onboardingDone &&
        next.periodIndex >= 1 &&
        !next.periodIncomeGranted) {
      if (next.availableBalance > 0) {
        next = next.copyWith(
          periodIncomeGranted: true,
          periodIncomeAmount: next.periodIncomeAmount > 0
              ? next.periodIncomeAmount
              : EconomyRules.periodIncome,
          periodIncomeLabel: next.periodIncomeLabel.isEmpty
              ? EconomyRules.periodIncomeLabel
              : next.periodIncomeLabel,
        );
      } else {
        next = _grantPeriodIncome(next);
      }
    }
    profile = next;
    await _persist();
  }

  /// Старые профили выбирали цели до пересмотра экономики. Сохраняем уже
  /// накопленное, но приводим стоимость именно этой цели к текущему каталогу.
  PlayerProfile _migrateGoalPrice(PlayerProfile p) {
    const prices = <String, int>{
      'Велосипед': 800,
      'Наушники': 300,
      'Плейстейшн': 1200,
      'Лодка': 1500,
      'Теннисная ракетка': 500,
      'Удочка': 400,
    };
    final title = p.goalTitle.replaceAll('\n', ' ').trim();
    final price = prices[title];
    if (price == null || price == p.goalPrice) return p;
    return p.copyWith(goalPrice: price);
  }

  Future<void> setIdentity({required String name, required int age}) async {
    profile = profile.copyWith(name: name.trim(), age: age);
    await _persist();
  }

  Future<void> completeOnboarding({
    required String name,
    required int age,
    required String goalTitle,
    required int goalPrice,
    required String goalImageAsset,
  }) async {
    final now = _now();
    profile = profile.copyWith(
      name: name.trim(),
      age: age,
      goalTitle: goalTitle,
      goalPrice: goalPrice,
      goalImageAsset: goalImageAsset,
      onboardingDone: true,
      satiety: 80,
      mood: 70,
      lastStatsAt: now.toIso8601String(),
      periodIndex: 1,
      periodPhase: PeriodPhase.planning,
      spentNecessary: 0,
      spentWants: 0,
      factSavings: 0,
      periodTaskDone: false,
      periodTaskRewardGranted: false,
      periodOpeningBalance: 0,
      clearPlan: true,
      lastPeriodSummary: '',
    );
    profile = PlayerRules.applyStreak(profile, now);
    profile = _grantPeriodIncome(profile);
    await _persist();
  }

  PlayerProfile _grantPeriodIncome(PlayerProfile p) {
    if (p.periodIncomeGranted) return p;
    return p.copyWith(
      availableBalance: p.availableBalance + EconomyRules.periodIncome,
      periodIncomeAmount: EconomyRules.periodIncome,
      periodIncomeLabel: EconomyRules.periodIncomeLabel,
      periodIncomeGranted: true,
    );
  }

  /// Подтвердить план (без списания). Сумма плана ≤ доступного.
  Future<bool> confirmBudgetPlan(BudgetPlan draft) async {
    if (profile.periodPhase != PeriodPhase.planning) return false;
    if (draft.necessary < 0 || draft.wants < 0 || draft.savings < 0) {
      return false;
    }
    if (draft.total > profile.availableBalance) return false;

    profile = profile.copyWith(
      plan: draft,
      periodPhase: PeriodPhase.playing,
    );
    await _persist();
    return true;
  }

  FinancialTask get currentTask =>
      FinancialTasks.forPeriod(profile.periodIndex.clamp(1, 999));

  /// Ответ на задание: навык без денежной награды.
  /// Ошибка не завершает задание — можно попробовать ещё.
  Future<TaskAnswerResult?> answerPeriodTask(String choiceId) async {
    if (profile.periodPhase != PeriodPhase.playing) return null;
    if (profile.periodTaskDone) return null;

    final task = currentTask;
    final choice = task.choices.where((c) => c.id == choiceId).firstOrNull;
    if (choice == null) return null;

    if (!choice.isCorrect) {
      return TaskAnswerResult(
        correct: false,
        explanation: choice.explanation,
        rewardGranted: false,
        rewardAmount: 0,
      );
    }

    // Верный ответ: отмечаем навык, деньги не начисляем.
    profile = profile.copyWith(
      periodTaskDone: true,
      periodTaskRewardGranted: true,
    );
    await _persist();

    return TaskAnswerResult(
      correct: true,
      explanation: choice.explanation,
      rewardGranted: true,
      rewardAmount: 0,
    );
  }

  /// Перевод в накопления (факт периода).
  Future<SavingsMoveResult> saveTowardGoal(int amount) async {
    if (amount <= 0) {
      return const SavingsMoveResult(ok: false, message: 'Введи сумму больше 0.');
    }
    if (profile.periodPhase != PeriodPhase.playing) {
      return const SavingsMoveResult(
        ok: false,
        message: 'Сначала подтверди план бюджета.',
      );
    }
    if (amount > profile.availableBalance) {
      return SavingsMoveResult(
        ok: false,
        message:
            'Не хватает денег. Доступно ${profile.availableBalance} ₽.',
      );
    }
    final room = (profile.goalPrice - profile.savedBalance).clamp(
      0,
      profile.goalPrice,
    );
    if (room <= 0) {
      return const SavingsMoveResult(
        ok: false,
        message: 'Цель уже накоплена!',
      );
    }
    final moved = amount.clamp(0, room);
    if (moved <= 0) {
      return const SavingsMoveResult(ok: false, message: 'Нечего переводить.');
    }

    profile = profile.copyWith(
      availableBalance: profile.availableBalance - moved,
      savedBalance: profile.savedBalance + moved,
      factSavings: profile.factSavings + moved,
    );
    await _persist();
    return SavingsMoveResult(
      ok: true,
      moved: moved,
      message:
          'В копилку +$moved ₽. Осталось накопить ${profile.remainingToGoal} ₽.',
    );
  }

  /// Снятие с накоплений обратно в доступно (с подтверждением в UI).
  Future<SavingsMoveResult> withdrawFromSavings(int amount) async {
    if (amount <= 0) {
      return const SavingsMoveResult(ok: false, message: 'Введи сумму больше 0.');
    }
    if (amount > profile.savedBalance) {
      return SavingsMoveResult(
        ok: false,
        message: 'В копилке только ${profile.savedBalance} ₽.',
      );
    }

    profile = profile.copyWith(
      availableBalance: profile.availableBalance + amount,
      savedBalance: profile.savedBalance - amount,
      factSavings: (profile.factSavings - amount).clamp(0, 1 << 30),
    );
    await _persist();
    return SavingsMoveResult(
      ok: true,
      moved: amount,
      message:
          'Снято $amount ₽. Накоплено теперь ${profile.savedBalance} ₽, '
          'до цели дальше.',
    );
  }

  /// Забрать полностью накопленную цель. Деньги из копилки расходуются на
  /// цель, а игрок сразу может выбрать следующую.
  Future<GoalClaimResult> claimCompletedGoal() async {
    if (!profile.isGoalComplete) {
      return const GoalClaimResult(
        ok: false,
        message: 'Сначала накопи всю сумму на цель.',
      );
    }
    final title = profile.goalTitle;
    profile = profile.copyWith(
      savedBalance: 0,
      goalTitle: '',
      goalPrice: 0,
      goalImageAsset: '',
      completedGoalTitles: [...profile.completedGoalTitles, title],
    );
    await _persist();
    return GoalClaimResult(
      ok: true,
      message: 'Цель «$title» получена! Теперь можно выбрать новую.',
    );
  }

  /// Выбрать следующую цель после онбординга или получения предыдущей.
  Future<void> chooseGoal({
    required String title,
    required int price,
    required String imageAsset,
  }) async {
    profile = profile.copyWith(
      goalTitle: title.trim(),
      goalPrice: price,
      goalImageAsset: imageAsset,
      savedBalance: 0,
    );
    await _persist();
  }

  /// Сброс профиля используется только из раздела взрослого после
  /// подтверждения. Хранилище очищается вместе с состоянием в памяти.
  Future<void> resetProfile() async {
    await _store.clear();
    profile = PlayerProfile.fresh();
    notifyListeners();
  }

  /// Демо-профиль для показа всех основных состояний приложения без ручного
  /// прохождения пяти игровых дней. Загружается только по явному действию
  /// взрослого и может быть сброшен на том же экране.
  Future<void> loadDemoProfile() async {
    profile = PlayerProfile.fresh().copyWith(
      name: 'Демо',
      age: 10,
      onboardingDone: true,
      availableBalance: 560,
      savedBalance: 200,
      goalTitle: 'Наушники',
      goalPrice: 300,
      goalImageAsset: 'assets/images/goals/headphones.png',
      streakDays: 5,
      lastOpenDay: PlayerRules.dayKey(_now()),
      satiety: 82,
      mood: 78,
      lastStatsAt: _now().toIso8601String(),
      periodIndex: 5,
      periodPhase: PeriodPhase.playing,
      periodIncomeGranted: true,
      periodIncomeAmount: EconomyRules.periodIncome,
      periodIncomeLabel: EconomyRules.periodIncomeLabel,
      periodOpeningBalance: 140,
      plan: const BudgetPlan(necessary: 160, wants: 100, savings: 80),
      inventory: const {'k0': 2, 'k3': 1, 'c0': 1, 'c4': 1, 's0': 1},
      equippedBodyKey: 'c0',
      equippedHeadKey: 'c4',
      boostedItemKeys: const ['c0', 'c4'],
      parkCompletedIds: const [
        'practice_lunch',
        'practice_day_plan',
        'practice_dream_save',
        'practice_plan_change',
        'practice_deal',
        'practice_receipt',
      ],
      periodPracticeCompletedIds: const ['practice_lunch', 'practice_day_plan'],
      completedGoalTitles: const ['Удочка'],
      periodHistory: const [
        'День 4. Нужное закрыто, и копилка пополнилась — хороший день. Остаток 140 ₽ переносится дальше.',
        'День 3. Нужное для Finzo закрыто. В копилку можно отложить в другой раз. Остаток 90 ₽ переносится дальше.',
        'День 2. В копилку отложили, а про еду и уход сегодня не заботились. Завтра вспомни про нужное. Остаток 60 ₽ переносится дальше.',
      ],
    );
    await _persist();
  }

  Future<bool> buyHouseItem({
    required HouseItemCategory category,
    required int index,
    int quantity = 1,
  }) async {
    if (profile.periodPhase != PeriodPhase.playing) return false;
    if (index < 0 || index >= HouseCatalog.countFor(category)) return false;
    if (quantity <= 0) return false;

    final shop = ShopCatalog.item(category, index);
    final key = shop.key;
    final qty = profile.inventoryQty(key);
    final room = shop.maxQty - qty;
    if (room <= 0) return false;

    final take = quantity.clamp(1, room);
    final price = shop.price * take;
    if (profile.availableBalance < price) return false;

    final next = Map<String, int>.from(profile.inventory);
    next[key] = qty + take;

    var spentNec = profile.spentNecessary;
    var spentWant = profile.spentWants;
    if (shop.bucket == BudgetBucket.necessary) {
      spentNec += price;
    } else if (shop.bucket == BudgetBucket.wants) {
      spentWant += price;
    }

    profile = profile.copyWith(
      availableBalance: profile.availableBalance - price,
      inventory: next,
      spentNecessary: spentNec,
      spentWants: spentWant,
    );
    await _persist();
    return true;
  }

  /// Единый пересчёт сытости/настроения. Безопасно вызывать часто:
  /// повторно за тот же момент времени ничего не списывает.
  Future<void> syncStats() async {
    final now = _now();
    final next = PlayerRules.applyStatsDecay(profile, now);
    if (next.lastStatsAt == profile.lastStatsAt &&
        next.satiety == profile.satiety &&
        next.mood == profile.mood) {
      return;
    }
    profile = next;
    await _persist();
  }

  Future<void> _decayBeforeMutation() async {
    profile = PlayerRules.applyStatsDecay(profile, _now());
  }

  Future<bool> useKitchenItem(int index) async {
    if (index < 0 || index >= HouseCatalog.kitchenCount) return false;
    await _decayBeforeMutation();
    if (profile.satiety >= 100) return false;

    final shop = ShopCatalog.item(HouseItemCategory.kitchen, index);
    final qty = profile.inventoryQty(shop.key);
    if (qty <= 0) return false;

    final next = Map<String, int>.from(profile.inventory);
    if (qty <= 1) {
      next.remove(shop.key);
    } else {
      next[shop.key] = qty - 1;
    }

    profile = profile.copyWith(
      inventory: next,
      satiety: (profile.satiety + shop.satietyDelta).clamp(0, 100),
      mood: (profile.mood + shop.moodDelta).clamp(0, 100),
      lastStatsAt: _now().toIso8601String(),
      periodCareUses: profile.periodCareUses + 1,
    );
    await _persist();
    return true;
  }

  /// Применить одежду или уход.
  /// Одежда: надеть в слот; бонус настроения +5 один раз ([boostedItemKeys]).
  Future<bool> useWearableOrCare({
    required HouseItemCategory category,
    required int index,
  }) async {
    if (category == HouseItemCategory.kitchen) return false;
    if (category == HouseItemCategory.clothes) {
      final r = await equipClothes(index);
      return r.ok;
    }

    await _decayBeforeMutation();
    final shop = ShopCatalog.item(category, index);
    final qty = profile.inventoryQty(shop.key);
    if (qty <= 0) return false;

    final next = Map<String, int>.from(profile.inventory);
    if (qty <= 1) {
      next.remove(shop.key);
    } else {
      next[shop.key] = qty - 1;
    }

    profile = profile.copyWith(
      inventory: next,
      satiety: (profile.satiety + shop.satietyDelta).clamp(0, 100),
      mood: (profile.mood + shop.moodDelta).clamp(0, 100),
      lastStatsAt: _now().toIso8601String(),
      periodCareUses: profile.periodCareUses + 1,
    );
    await _persist();
    return true;
  }

  /// Надеть купленную одежду. Повторное надевание бесплатно и без нового бонуса.
  Future<EquipClothesResult> equipClothes(int index) async {
    await _decayBeforeMutation();
    final shop = ShopCatalog.item(HouseItemCategory.clothes, index);
    final qty = profile.inventoryQty(shop.key);
    if (qty <= 0) {
      return const EquipClothesResult(ok: false);
    }

    final item = WardrobeCatalog.byIndex(index);
    final alreadyBoosted = profile.boostedItemKeys.contains(shop.key);
    var moodGain = 0.0;
    var boosted = profile.boostedItemKeys;
    var mood = profile.mood;

    if (!alreadyBoosted && shop.moodDelta > 0) {
      final before = mood;
      mood = (mood + shop.moodDelta).clamp(0, 100);
      moodGain = mood - before;
      boosted = [...boosted, shop.key];
    }

    profile = profile.copyWith(
      mood: mood,
      lastStatsAt: _now().toIso8601String(),
      boostedItemKeys: boosted,
      equippedBodyKey: item.slot == WardrobeSlot.body ? shop.key : null,
      equippedHeadKey: item.slot == WardrobeSlot.head ? shop.key : null,
    );
    await _persist();
    return EquipClothesResult(
      ok: true,
      moodGain: moodGain,
      firstBoost: !alreadyBoosted,
    );
  }

  /// Снять вещь слота. Настроение не падает; вещь остаётся в инвентаре.
  Future<bool> unequipClothesSlot(WardrobeSlot slot) async {
    if (slot == WardrobeSlot.body && profile.equippedBodyKey == null) {
      return false;
    }
    if (slot == WardrobeSlot.head && profile.equippedHeadKey == null) {
      return false;
    }
    profile = profile.copyWith(
      clearEquippedBody: slot == WardrobeSlot.body,
      clearEquippedHead: slot == WardrobeSlot.head,
    );
    await _persist();
    return true;
  }

  Future<bool> unequipClothesKey(String key) async {
    if (profile.equippedBodyKey == key) {
      return unequipClothesSlot(WardrobeSlot.body);
    }
    if (profile.equippedHeadKey == key) {
      return unequipClothesSlot(WardrobeSlot.head);
    }
    return false;
  }

  Future<void> markPracticeTipShown() async {
    if (profile.practiceTipShown) return;
    profile = profile.copyWith(practiceTipShown: true);
    await _persist();
  }

  Future<void> markMessagesSeen(Iterable<String> ids) async {
    final merged = {...profile.seenMessageIds, ...ids}.toList();
    if (merged.length == profile.seenMessageIds.length) return;
    profile = profile.copyWith(seenMessageIds: merged);
    await _persist();
  }

  bool get isFullyFed => profile.satiety >= 100;

  Future<void> markDayEndIntroShown() async {
    if (profile.dayEndIntroShown) return;
    profile = profile.copyWith(dayEndIntroShown: true);
    await _persist();
  }

  Future<void> markParkExerciseDone(String id) async {
    if (id.isEmpty) return;
    // Пишем practice_*. Старые park_* в профиле не приравниваем к новым.
    const openAliases = {
      'budget_split': 'practice_day_plan',
      'budget_fun': 'practice_lunch',
      'save_pick': 'practice_dream_save',
      'save_withdraw': 'practice_plan_change',
      'shop_basket': 'practice_deal',
      'shop_compare': 'practice_receipt',
      'park_bike': 'practice_day_plan',
      'park_club': 'practice_lunch',
      'park_music': 'practice_dream_save',
      'park_boat': 'practice_plan_change',
      'park_tennis': 'practice_deal',
      'park_fish': 'practice_receipt',
    };
    final canonical = openAliases[id] ?? id;
    final existing = profile.parkCompletedIds.toSet();
    final ids = existing.contains(canonical)
        ? existing.toList()
        : [...existing, canonical];
    final today = {...profile.periodPracticeCompletedIds, canonical}.toList();
    profile = profile.copyWith(
      parkCompletedIds: ids,
      periodPracticeCompletedIds: today,
      periodTaskDone: true,
    );
    await _persist();
  }

  Future<bool> finishPeriod() async {
    if (profile.periodPhase != PeriodPhase.playing) return false;
    final plan = profile.plan ??
        const BudgetPlan(necessary: 0, wants: 0, savings: 0);

    final summary = PlayerRules.buildPeriodSummary(
      periodIndex: profile.periodIndex,
      planNecessary: plan.necessary,
      planWants: plan.wants,
      planSavings: plan.savings,
      spentNecessary: profile.spentNecessary,
      spentWants: profile.spentWants,
      factSavings: profile.factSavings,
      remainingBalance: profile.availableBalance,
      careUses: profile.periodCareUses,
      satiety: profile.satiety,
    );

    profile = profile.copyWith(
      periodPhase: PeriodPhase.results,
      lastPeriodSummary: summary,
      periodHistory: [summary, ...profile.periodHistory].take(30).toList(),
    );
    await _persist();
    return true;
  }

  /// Старт следующего периода: остаток переносится, новый доход один раз.
  Future<bool> startNextPeriod() async {
    if (profile.periodPhase != PeriodPhase.results) return false;

    profile = profile.copyWith(
      periodIndex: profile.periodIndex + 1,
      periodPhase: PeriodPhase.planning,
      periodIncomeGranted: false,
      periodOpeningBalance: profile.availableBalance,
      periodIncomeAmount: 0,
      periodIncomeLabel: '',
      clearPlan: true,
      spentNecessary: 0,
      spentWants: 0,
      factSavings: 0,
      periodTaskDone: false,
      periodTaskRewardGranted: false,
      periodCareUses: 0,
      periodPracticeCompletedIds: const [],
    );
    profile = _grantPeriodIncome(profile);
    await _persist();
    return true;
  }

  /// Подсказка, если факт категории выше плана.
  String? overPlanHint(BudgetBucket bucket, int extraSpend) {
    final plan = profile.plan;
    if (plan == null) return null;
    final spent = switch (bucket) {
      BudgetBucket.necessary => profile.spentNecessary,
      BudgetBucket.wants => profile.spentWants,
      BudgetBucket.savings => profile.factSavings,
    };
    final planned = switch (bucket) {
      BudgetBucket.necessary => plan.necessary,
      BudgetBucket.wants => plan.wants,
      BudgetBucket.savings => plan.savings,
    };
    if (spent + extraSpend <= planned) return null;
    return 'Это больше плана «${bucket.titleRu}» '
        '($planned ₽). Можно купить, если хватает денег — '
        'вечером увидишь сравнение.';
  }
}

/// In-memory store for UI_SHOT wardrobe sessions (не пишет в SharedPreferences).
class _EphemeralProfileStore extends PlayerProfileStore {
  PlayerProfile? _p;

  @override
  Future<PlayerProfile> load() async => _p ?? PlayerProfile.fresh();

  @override
  Future<void> save(PlayerProfile profile) async => _p = profile;
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
