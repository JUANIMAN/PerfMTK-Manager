import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/providers/app_profile_visibility_provider.dart';
import 'package:manager/presentation/screens/app_profiles_screen.dart';
import 'package:manager/presentation/screens/perf_config_screen.dart';
import 'package:manager/presentation/screens/profiles_screen.dart';
import 'package:manager/presentation/screens/settings_screen.dart';
import 'package:manager/presentation/screens/thermal_screen.dart';
import 'package:manager/core/utils/update_checker.dart';
import 'package:manager/config/app_constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum NavScreens { profiles, appProfiles, perfConfig, thermal }

class AppNavigator extends ConsumerStatefulWidget {
  const AppNavigator({super.key});

  @override
  ConsumerState<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends ConsumerState<AppNavigator> {
  final FlutterLocalization localization = FlutterLocalization.instance;
  NavScreens _currentScreen = NavScreens.profiles;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final updateChecker = UpdateChecker(
      owner: 'JUANIMAN',
      repo: 'PerfMTK-Manager',
      currentVersion: packageInfo.version,
      currentLanguage: localization.currentLocale!.localeIdentifier,
    );
    if (mounted) {
      await updateChecker.checkForUpdates(context);
    }
  }

  /// Ordered list of screens currently visible in the nav bar.
  List<NavScreens> _screenList(bool showAppProfiles) => [
        NavScreens.profiles,
        if (showAppProfiles) NavScreens.appProfiles,
        NavScreens.perfConfig,
        NavScreens.thermal,
      ];

  int _resolvedIndex(bool showAppProfiles) {
    final list = _screenList(showAppProfiles);
    if (!list.contains(_currentScreen)) {
      _currentScreen = NavScreens.profiles;
    }
    return list.indexOf(_currentScreen);
  }

  NavScreens _screenFromIndex(int index, bool showAppProfiles) {
    final list = _screenList(showAppProfiles);
    return list[index.clamp(0, list.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    final showAppProfiles =
        ref.watch(appProfileVisibilityProvider).value ?? false;
    final selectedIndex = _resolvedIndex(showAppProfiles);

    return Scaffold(
      extendBody: true, // body goes behind the nav bar for the glass effect
      appBar: AppBar(
        title: const Text('PerfMTK Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            tooltip: 'Settings',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(selectedIndex, showAppProfiles),
      bottomNavigationBar: _buildGlassNavBar(showAppProfiles, selectedIndex),
    );
  }

  Widget _buildBody(int selectedIndex, bool showAppProfiles) {
    // Use AnimatedSwitcher for smooth cross-fade between tabs
    final screens = [
      const ProfilesScreen(),
      if (showAppProfiles) const AppProfilesScreen(),
      const PerfConfigScreen(),
      const ThermalScreen(),
    ];

    return AnimatedSwitcher(
      duration: AppConstants.animationNormal,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
      child: KeyedSubtree(
        key: ValueKey(selectedIndex),
        child: screens[selectedIndex],
      ),
    );
  }

  Widget _buildGlassNavBar(bool showAppProfiles, int selectedIndex) {
    final theme = Theme.of(context);
    final destinations = <NavigationDestination>[
      _navDest(Icons.tune_rounded, Icons.tune, AppLocale.profiles),
      if (showAppProfiles)
        _navDest(
          Icons.apps_rounded,
          Icons.apps_outlined,
          AppLocale.appProfiles,
        ),
      _navDest(
        Icons.speed_rounded,
        Icons.speed_outlined,
        AppLocale.perfConfig,
      ),
      _navDest(
        Icons.thermostat_rounded,
        Icons.thermostat_outlined,
        AppLocale.thermal,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacing16,
          AppConstants.spacing8,
          AppConstants.spacing16,
          AppConstants.spacing4,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _currentScreen = _screenFromIndex(index, showAppProfiles);
                  });
                },
                destinations: destinations,
                animationDuration: AppConstants.animationNormal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  NavigationDestination _navDest(
    IconData selectedIcon,
    IconData icon,
    String labelKey,
  ) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      label: AppLocale.getValue(labelKey).getString(context),
    );
  }
}
