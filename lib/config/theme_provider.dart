import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider para SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// Provider principal del ThemeMode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.read(sharedPreferencesProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeModeKey = 'themeMode';
  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final savedThemeMode = _prefs.getString(_themeModeKey);

    state = savedThemeMode != null
        ? ThemeMode.values.firstWhere(
          (e) => e.toString() == savedThemeMode,
      orElse: () => ThemeMode.system,
    )
        : ThemeMode.system;

    _updateSystemUIOverlayStyle();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state != mode) {
      state = mode;
      await _prefs.setString(_themeModeKey, mode.toString());
      _updateSystemUIOverlayStyle();
    }
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }

  void _updateSystemUIOverlayStyle() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = state == ThemeMode.dark ||
        (state == ThemeMode.system && brightness == Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }
}

// Provider derivado para obtener si está en modo oscuro
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;

  return themeMode == ThemeMode.dark ||
      (themeMode == ThemeMode.system && brightness == Brightness.dark);
});
