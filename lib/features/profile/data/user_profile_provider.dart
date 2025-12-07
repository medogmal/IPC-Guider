import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/user_profile.dart';

const _prefsKey = 'ipc_user_profile.v1';

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(UserProfile.empty()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final map = json.decode(raw) as Map<String, dynamic>;
      state = UserProfile.fromJson(map);
    } catch (_) {
      // ignore corrupted state, keep empty
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final enc = json.encode(state.toJson());
    await prefs.setString(_prefsKey, enc);
  }

  Future<void> updateProfile({
    String? name,
    String? title,
    String? profession,
  }) async {
    state = state.copyWith(
      name: name,
      title: title,
      profession: profession,
    );
    await _persist();
  }

  Future<void> clearProfile() async {
    state = UserProfile.empty();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>(
        (ref) => UserProfileNotifier());

