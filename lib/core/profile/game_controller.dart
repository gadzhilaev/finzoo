import 'package:flutter/foundation.dart';

import 'player_profile.dart';
import 'player_profile_store.dart';
import 'player_rules.dart';

/// Живое состояние игрока: стрик, баланс, сытость, настроение.
class GameController extends ChangeNotifier {
  GameController({
    required PlayerProfile profile,
    PlayerProfileStore? store,
    DateTime Function()? now,
  }) : _profile = profile,
       _store = store ?? PlayerProfileStore(),
       _now = now ?? DateTime.now;

  final PlayerProfileStore _store;
  final DateTime Function() _now;

  PlayerProfile _profile;
  PlayerProfile get profile => _profile;

  static Future<GameController> bootstrap() async {
    final store = PlayerProfileStore();
    final loaded = await store.load();
    final controller = GameController(profile: loaded, store: store);
    await controller.onAppOpen();
    return controller;
  }

  Future<void> _persist() async {
    await _store.save(_profile);
    notifyListeners();
  }

  Future<void> onAppOpen() async {
    final now = _now();
    var next = PlayerRules.applyStatsDecay(_profile, now);
    next = PlayerRules.applyStreak(next, now);
    next = PlayerRules.applyParentAllowance(next, now);
    _profile = next;
    await _persist();
  }

  Future<void> setIdentity({required String name, required int age}) async {
    _profile = _profile.copyWith(name: name.trim(), age: age);
    await _persist();
  }

  Future<void> completeOnboarding({
    required String name,
    required int age,
    required String goalTitle,
    required int goalPrice,
  }) async {
    final now = _now();
    _profile = _profile.copyWith(
      name: name.trim(),
      age: age,
      goalTitle: goalTitle,
      goalPrice: goalPrice,
      onboardingDone: true,
      availableBalance: _profile.availableBalance > 0
          ? _profile.availableBalance
          : PlayerRules.initialParentGift,
      satiety: 80,
      mood: 70,
      lastStatsAt: now.toIso8601String(),
    );
    _profile = PlayerRules.applyStreak(_profile, now);
    _profile = PlayerRules.applyParentAllowance(_profile, now);
    await _persist();
  }

  Future<void> completeDailyTask() async {
    final now = _now();
    final day = PlayerRules.dayKey(now);
    if (_profile.dailyTaskDoneDay == day) return;

    _profile = _profile.copyWith(
      dailyTaskDoneDay: day,
      availableBalance: _profile.availableBalance + PlayerRules.dailyTaskReward,
      satiety: (_profile.satiety + 15).clamp(0, 100),
      mood: (_profile.mood + 12).clamp(0, 100),
      lastStatsAt: now.toIso8601String(),
    );
    await _persist();
  }

  /// Отложить часть «доступно» в накопления.
  Future<void> saveTowardGoal(int amount) async {
    if (amount <= 0) return;
    final take = amount.clamp(0, _profile.availableBalance);
    final room = (_profile.goalPrice - _profile.savedBalance).clamp(
      0,
      _profile.goalPrice,
    );
    final moved = take.clamp(0, room);
    if (moved <= 0) return;
    _profile = _profile.copyWith(
      availableBalance: _profile.availableBalance - moved,
      savedBalance: _profile.savedBalance + moved,
    );
    await _persist();
  }
}
