import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  static const String _themeModeKey = 'themeMode';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString(_themeModeKey);

    _themeMode = savedThemeMode != null
        ? ThemeMode.values.firstWhere(
            (e) => e.toString() == savedThemeMode,
            orElse: () => ThemeMode.light,
          )
        : ThemeMode.system;

    _updateSystemUIOverlayStyle();
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
    setThemeMode(
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  void _updateSystemUIOverlayStyle() {
    bool isDark = _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }
}

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return RotationTransition(
          turns: animation,
          child: child,
        );
      },
      child: IconButton(
        key: ValueKey<ThemeMode>(
            Theme.of(context).brightness == Brightness.light
                ? ThemeMode.light
                : ThemeMode.dark),
        icon: Icon(
          Theme.of(context).brightness == Brightness.light
              ? Icons.dark_mode
              : Icons.light_mode,
        ),
        onPressed: () {
          final themeProvider = context.read<ThemeProvider>();
          themeProvider.toggleTheme();
        },
      ),
    );
  }
}
