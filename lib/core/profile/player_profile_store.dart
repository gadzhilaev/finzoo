import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'player_profile.dart';

class PlayerProfileStore {
  static const _key = 'finzoo_player_profile_v1';

  Future<PlayerProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return PlayerProfile.fresh();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PlayerProfile.fromJson(Map<String, Object?>.from(map));
    } catch (_) {
      return PlayerProfile.fresh();
    }
  }

  Future<void> save(PlayerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }
}
