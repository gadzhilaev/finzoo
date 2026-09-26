import 'package:flutter/foundation.dart';

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
}
