import 'package:flutter/foundation.dart';

import 'house_catalog.dart';
import 'player_profile.dart';
import 'player_profile_store.dart';
import 'player_rules.dart';

/// Живое состояние игрока: стрик, баланс, сытость, настроение.
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
    final store = PlayerProfileStore();
    final loaded = await store.load();
    final controller = GameController(profile: loaded, store: store);
    await controller.onAppOpen();
    return controller;
  }

  Future<void> _persist() async {
    await _store.save(profile);
    notifyListeners();
  }

  Future<void> onAppOpen() async {
    final now = _now();
    var next = PlayerRules.applyStatsDecay(profile, now);
    next = PlayerRules.applyStreak(next, now);
    next = PlayerRules.applyParentAllowance(next, now);
    profile = next;
    await _persist();
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
      availableBalance: profile.availableBalance > 0
          ? profile.availableBalance
          : PlayerRules.initialParentGift,
      satiety: 80,
      mood: 70,
      lastStatsAt: now.toIso8601String(),
    );
    profile = PlayerRules.applyStreak(profile, now);
    profile = PlayerRules.applyParentAllowance(profile, now);
    await _persist();
  }

  Future<void> completeDailyTask() async {
    final now = _now();
    final day = PlayerRules.dayKey(now);
    if (profile.dailyTaskDoneDay == day) return;

    profile = profile.copyWith(
      dailyTaskDoneDay: day,
      availableBalance: profile.availableBalance + PlayerRules.dailyTaskReward,
      satiety: (profile.satiety + 15).clamp(0, 100),
      mood: (profile.mood + 12).clamp(0, 100),
      lastStatsAt: now.toIso8601String(),
    );
    await _persist();
  }

  /// Отложить часть «доступно» в накопления.
  Future<void> saveTowardGoal(int amount) async {
    if (amount <= 0) return;
    final take = amount.clamp(0, profile.availableBalance);
    final room = (profile.goalPrice - profile.savedBalance).clamp(
      0,
      profile.goalPrice,
    );
    final moved = take.clamp(0, room);
    if (moved <= 0) return;
    profile = profile.copyWith(
      availableBalance: profile.availableBalance - moved,
      savedBalance: profile.savedBalance + moved,
    );
    await _persist();
  }

  /// Купить слот дома. Еда — стопка (`quantity`); одежда/душ — максимум 1.
  Future<bool> buyHouseItem({
    required HouseItemCategory category,
    required int index,
    int quantity = 1,
  }) async {
    if (index < 0 || index >= HouseCatalog.countFor(category)) return false;
    if (quantity <= 0) return false;

    final key = HouseCatalog.key(category, index);
    final qty = profile.inventoryQty(key);
    final maxQty = HouseCatalog.maxQty(category);
    final room = maxQty - qty;
    if (room <= 0) return false;

    final take = quantity.clamp(1, room);
    final price = HouseCatalog.itemPrice * take;
    if (profile.availableBalance < price) return false;

    final next = Map<String, int>.from(profile.inventory);
    next[key] = qty + take;
    profile = profile.copyWith(
      availableBalance: profile.availableBalance - price,
      inventory: next,
    );
    await _persist();
    return true;
  }

  /// Съесть 1 порцию еды: −1 из инвентаря, +сытость.
  /// `false` если нет еды или белка уже сыта.
  Future<bool> useKitchenItem(int index) async {
    if (index < 0 || index >= HouseCatalog.kitchenCount) return false;
    if (profile.satiety >= 100) return false;

    final key = HouseCatalog.key(HouseItemCategory.kitchen, index);
    final qty = profile.inventoryQty(key);
    if (qty <= 0) return false;

    final next = Map<String, int>.from(profile.inventory);
    if (qty <= 1) {
      next.remove(key);
    } else {
      next[key] = qty - 1;
    }

    profile = profile.copyWith(
      inventory: next,
      satiety: (profile.satiety + HouseCatalog.foodSatietyBoost).clamp(0, 100),
      lastStatsAt: _now().toIso8601String(),
    );
    await _persist();
    return true;
  }

  bool get isFullyFed => profile.satiety >= 100;
}
