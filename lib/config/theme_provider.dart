import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/providers/shared_preferences_provider.dart';

// Provider principal del ThemeMode
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _themeModeKey = 'themeMode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedThemeMode = prefs.getString(_themeModeKey);

    final initialMode = savedThemeMode != null
        ? ThemeMode.values.firstWhere(
            (e) => e.toString() == savedThemeMode,
            orElse: () => ThemeMode.system,
          )
        : ThemeMode.system;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemUIOverlayStyle();
    });

    return initialMode;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state != mode) {
      state = mode;
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_themeModeKey, mode.toString());
      _updateSystemUIOverlayStyle();
    }
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }

  void _updateSystemUIOverlayStyle() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark =
        state == ThemeMode.dark ||
        (state == ThemeMode.system && brightness == Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }
}

// Provider derivado para obtener si está en modo oscuro
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  final brightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  return themeMode == ThemeMode.dark ||
      (themeMode == ThemeMode.system && brightness == Brightness.dark);
});
