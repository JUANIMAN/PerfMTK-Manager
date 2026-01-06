import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para controlar la visibilidad de App Profiles
final appProfileVisibilityProvider = StateNotifierProvider<AppProfileVisibilityNotifier, bool>((ref) {
  return AppProfileVisibilityNotifier();
});

class AppProfileVisibilityNotifier extends StateNotifier<bool> {
  static const String _visibilityKey = 'show_app_profiles_tab';

  AppProfileVisibilityNotifier() : super(false) {
    _loadVisibility();
  }

  Future<void> _loadVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_visibilityKey) ?? false;
  }

  Future<void> show() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_visibilityKey, true);
  }

  Future<void> hide() async {
    state = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_visibilityKey, false);
  }
}