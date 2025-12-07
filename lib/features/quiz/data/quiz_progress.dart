import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/quiz_models.dart';

const _prefsKey = 'ipc_quiz_progress.v1';

class ProgressStore extends StateNotifier<Map<String, ModuleProgress>> {
  ProgressStore() : super(const {}) {
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final map = json.decode(raw) as Map<String, dynamic>;
      final res = <String, ModuleProgress>{};
      map.forEach((k, v) => res[k] = ModuleProgress.fromJson(v));
      state = res;
    } catch (_) {
      // ignore corrupted state, keep empty
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final enc = json.encode(state.map((k, v) => MapEntry(k, v.toJson())));
    await prefs.setString(_prefsKey, enc);
  }

  ModuleProgress get(String module) {
    return state[module] ?? ModuleProgress.empty(module);
  }

  Future<void> updateStageResult({
    required String module,
    required int stage, // 1..5
    required int score, // 0..10
    required bool passed,
  }) async {
    final prev = get(module);
    final newBest = List<int>.from(prev.bestScores);
    if (score > newBest[stage - 1]) newBest[stage - 1] = score;

    final newBadges = List<bool>.from(prev.stageBadgesEarned);
    if (passed) newBadges[stage - 1] = true;

    var unlocked = prev.unlockedStage;
    if (passed && stage < 5 && unlocked < stage + 1) {
      unlocked = stage + 1;
    }

    final allEarned = newBadges.every((b) => b);
    final finalBadge = allEarned ? true : prev.moduleBadgeEarned;

    final updated = prev.copyWith(
      unlockedStage: unlocked,
      bestScores: newBest,
      stageBadgesEarned: newBadges,
      moduleBadgeEarned: finalBadge,
      clearInStageProgress: true, // Clear in-stage progress when stage completes
    );

    state = {...state, module: updated};
    await _persist();
  }

  /// Save in-stage progress (called after each question)
  Future<void> saveInStageProgress({
    required String module,
    required int stage,
    required int currentQuestionIndex,
    required int correctCount,
    required List<int?> selectedAnswers,
  }) async {
    final prev = get(module);
    final inStageProgress = InStageProgress(
      module: module,
      stage: stage,
      currentQuestionIndex: currentQuestionIndex,
      correctCount: correctCount,
      selectedAnswers: selectedAnswers,
    );

    final updated = prev.copyWith(inStageProgress: inStageProgress);
    state = {...state, module: updated};
    await _persist();
  }

  /// Clear in-stage progress (when user restarts or abandons quiz)
  Future<void> clearInStageProgress(String module) async {
    final prev = get(module);
    final updated = prev.copyWith(clearInStageProgress: true);
    state = {...state, module: updated};
    await _persist();
  }
}

final progressStoreProvider =
    StateNotifierProvider<ProgressStore, Map<String, ModuleProgress>>(
        (ref) => ProgressStore());
