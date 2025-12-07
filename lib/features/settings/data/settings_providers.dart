import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/settings_model.dart';

// Settings repository provider
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

// Settings state provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(AppSettings.defaultSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _repository.loadSettings();
    state = settings;
  }

  Future<void> setTextScaleFactor(double factor) async {
    state = state.copyWith(textScaleFactor: factor);
    await _repository.saveSettings(state);
  }

  Future<void> resetToDefaults() async {
    state = AppSettings.defaultSettings();
    await _repository.saveSettings(state);
  }
}

class SettingsRepository {
  static const String _textScaleFactorKey = 'text_scale_factor';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return AppSettings(
      textScaleFactor: prefs.getDouble(_textScaleFactorKey) ?? 1.0,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble(_textScaleFactorKey, settings.textScaleFactor);
  }

  Future<void> clearAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_textScaleFactorKey);
  }
}
