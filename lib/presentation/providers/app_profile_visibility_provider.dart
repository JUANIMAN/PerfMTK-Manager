import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/providers/shared_preferences_provider.dart';
import 'package:manager/presentation/providers/config_repository_provider.dart';

/// Provider que controla la visibilidad de la pestaña App Profiles.
final appProfileVisibilityProvider =
    AsyncNotifierProvider<AppProfileVisibilityNotifier, bool>(
      AppProfileVisibilityNotifier.new,
    );

class AppProfileVisibilityNotifier extends AsyncNotifier<bool> {
  static const String _visibilityKey = 'show_app_profiles_tab';

  @override
  Future<bool> build() async {
    final results = await Future.wait([_readPrefs(), _configFileExists()]);

    final prefsVisible = results[0];
    final fileExists = results[1];
    final visible = prefsVisible || fileExists;

    if (fileExists && !prefsVisible) {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(_visibilityKey, true);
    }

    return visible;
  }

  Future<bool> _readPrefs() async {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(_visibilityKey) ?? false;
  }

  Future<bool> _configFileExists() async {
    try {
      return await ref.read(configRepositoryProvider).configExists();
    } catch (_) {
      return false;
    }
  }

  Future<void> show() async {
    state = const AsyncData(true);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_visibilityKey, true);
  }

  Future<void> hide() async {
    state = const AsyncData(false);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_visibilityKey, false);
  }
}
