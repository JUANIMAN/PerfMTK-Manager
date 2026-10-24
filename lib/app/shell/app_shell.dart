import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/app/shell/app_lifecycle_gate.dart';
import 'package:manager/app/shell/app_top_bar.dart';
import 'package:manager/app/shell/fade_through_tab_body.dart';
import 'package:manager/app/shell/floating_nav_bar.dart';
import 'package:manager/app/shell/nav_tab.dart';
import 'package:manager/features/app_profiles/presentation/app_profiles_screen.dart';
import 'package:manager/features/battery/presentation/battery_screen.dart';
import 'package:manager/features/perf_config/presentation/perf_config_screen.dart';
import 'package:manager/features/profiles/presentation/profiles_screen.dart';

/// Home route: top bar + state-preserving tab body + floating navigation bar.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static Widget _screenFor(NavTab tab) => switch (tab) {
    NavTab.profiles => const ProfilesScreen(),
    NavTab.battery => const BatteryScreen(),
    NavTab.appProfiles => const AppProfilesScreen(),
    NavTab.perfConfig => const PerfConfigScreen(),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(effectiveNavTabProvider);
    final showAppProfiles = ref.watch(
      visibleNavTabsProvider.select((tabs) => tabs.contains(NavTab.appProfiles)),
    );

    return AppLifecycleGate(
      child: Scaffold(
        extendBody: true,
        appBar: AppTopBar(tab: tab),
        body: FadeThroughTabBody(
          currentTab: tab,
          showAppProfiles: showAppProfiles,
          tabBuilder: _screenFor,
        ),
        bottomNavigationBar: const FloatingNavBar(),
      ),
    );
  }
}
