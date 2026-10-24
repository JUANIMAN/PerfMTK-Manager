import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/features/app_profiles/presentation/app_profile_visibility_provider.dart';
import 'package:manager/l10n/l10n.dart';

/// Top-level destinations of the bottom navigation bar.
enum NavTab {
  profiles(Icons.tune_rounded, Icons.tune),
  battery(Icons.battery_charging_full_rounded, Icons.battery_charging_full_outlined),
  appProfiles(Icons.apps_rounded, Icons.apps_outlined),
  perfConfig(Icons.speed_rounded, Icons.speed_outlined);

  const NavTab(this.selectedIcon, this.unselectedIcon);
  final IconData selectedIcon;
  final IconData unselectedIcon;

  /// Short label shown in the navigation bar.
  String label(AppLocalizations l) => switch (this) {
    NavTab.profiles => l.profiles,
    NavTab.battery => l.battery,
    NavTab.appProfiles => l.appProfiles,
    NavTab.perfConfig => l.perfConfig,
  };
}

/// Tabs currently offered by the bar (App Profiles is opt-in).
final visibleNavTabsProvider = Provider<List<NavTab>>((ref) {
  final showAppProfiles =
      ref.watch(appProfileVisibilityProvider).value ?? false;
  return [
    NavTab.profiles,
    NavTab.battery,
    if (showAppProfiles) NavTab.appProfiles,
    NavTab.perfConfig,
  ];
});

/// The tab the user last tapped (may no longer be visible).
class SelectedNavTabNotifier extends Notifier<NavTab> {
  @override
  NavTab build() => NavTab.profiles;

  void select(NavTab tab) => state = tab;
}

final selectedNavTabProvider =
    NotifierProvider<SelectedNavTabNotifier, NavTab>(
      SelectedNavTabNotifier.new,
    );

/// Selected tab, falling back to [NavTab.profiles] when it is hidden.
/// Both the body and the bar read this, so they can never disagree.
final effectiveNavTabProvider = Provider<NavTab>((ref) {
  final tabs = ref.watch(visibleNavTabsProvider);
  final selected = ref.watch(selectedNavTabProvider);
  return tabs.contains(selected) ? selected : NavTab.profiles;
});
