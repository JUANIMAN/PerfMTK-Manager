import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider que controla la visibilidad de la pestaña App Profiles.
final appProfileVisibilityProvider =
AsyncNotifierProvider<AppProfileVisibilityNotifier, bool>(
  AppProfileVisibilityNotifier.new,
);

class AppProfileVisibilityNotifier extends AsyncNotifier<bool> {
  static const String _visibilityKey = 'show_app_profiles_tab';

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_visibilityKey) ?? false;
  }

  Future<void> show() async {
    state = const AsyncData(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_visibilityKey, true);
  }

  Future<void> hide() async {
    state = const AsyncData(false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_visibilityKey, false);
  }
}