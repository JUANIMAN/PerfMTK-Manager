import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  static const String _themeModeKey = 'themeMode';
  static const String _firstLaunchKey = 'isFirstLaunch';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider(BuildContext context) {
    _loadThemePreference(context);
  }

  void _loadThemePreference(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if it's the first launch
    bool isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;

    if (isFirstLaunch) {
      // First launch, use system mode
      _themeMode = ThemeMode.system;

      // Mark that first launch is complete
      await prefs.setBool(_firstLaunchKey, false);
    } else {
      // Not first launch, load user's previous preference
      final savedThemeMode = prefs.getString(_themeModeKey);

      if (savedThemeMode != null) {
        _themeMode = ThemeMode.values.firstWhere(
              (e) => e.toString() == savedThemeMode,
          orElse: () => ThemeMode.light, // Default to light if something goes wrong
        );
      } else {
        // If no saved preference, default to light
        _themeMode = ThemeMode.light;
      }
    }

    _updateSystemUIOverlayStyle(context);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeMode.toString());
    }
  }

  void toggleTheme() {
    setThemeMode(_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  void _updateSystemUIOverlayStyle(BuildContext context) {
    bool isDark = _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            View.of(context).platformDispatcher.platformBrightness == Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }
}

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          icon: Icon(
            themeProvider.themeMode == ThemeMode.light
                ? Icons.dark_mode
                : Icons.light_mode,
          ),
          onPressed: () {
            themeProvider.toggleTheme();
          },
        );
      },
    );
  }
}