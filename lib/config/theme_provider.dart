import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getInt('themeMode');
    if (savedThemeMode != null) {
      _themeMode = ThemeMode.values[savedThemeMode];
      notifyListeners();
    }
  }

  void toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
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
