import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/providers/app_profile_visibility_provider.dart';
import 'package:manager/presentation/screens/app_profiles_screen.dart';
import 'package:manager/presentation/screens/profiles_screen.dart';
import 'package:manager/presentation/screens/settings_screen.dart';
import 'package:manager/presentation/screens/thermal_screen.dart';
import 'package:manager/core/utils/update_checker.dart';
import 'package:manager/config/app_constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum NavScreens { profiles, appProfiles, thermal }

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

  /// Calcula el índice para `IndexedStack` y `NavigationBar`
  int _resolvedIndex(bool showAppProfiles) {
    // Normalizar si la pestaña desaparece.
    if (!showAppProfiles && _currentScreen == NavScreens.appProfiles) {
      _currentScreen = NavScreens.profiles;
    }

    if (!showAppProfiles) {
      // Solo hay 2 destinos: profiles=0, thermal=1
      return _currentScreen == NavScreens.profiles ? 0 : 1;
    }

    // 3 destinos: profiles=0, appProfiles=1, thermal=2
    return _currentScreen.index;
  }

  NavScreens _screenFromIndex(int index, bool showAppProfiles) {
    if (!showAppProfiles) {
      return index == 0 ? NavScreens.profiles : NavScreens.thermal;
    }
    return NavScreens.values[index];
  }

  @override
  Widget build(BuildContext context) {
    final showAppProfiles =
        ref.watch(appProfileVisibilityProvider).value ?? false;

    final selectedIndex = _resolvedIndex(showAppProfiles);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PerfMTK Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          const ProfilesScreen(),
          if (showAppProfiles) const AppProfilesScreen(),
          const ThermalScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(showAppProfiles, selectedIndex),
    );
  }

  Widget _buildBottomNav(bool showAppProfiles, int selectedIndex) {
    final destinations = <NavigationDestination>[
      _navDestination(NavScreens.profiles, Icons.tune, 'profiles'),
      if (showAppProfiles)
        _navDestination(NavScreens.appProfiles, Icons.apps, 'appProfiles'),
      _navDestination(NavScreens.thermal, Icons.thermostat, 'thermal'),
    ];

    return Container(
      margin: AppConstants.paddingNormal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            HapticFeedback.mediumImpact();
            setState(() {
              _currentScreen = _screenFromIndex(index, showAppProfiles);
            });
          },
          destinations: destinations,
          animationDuration: AppConstants.animationNormal,
        ),
      ),
    );
  }

  NavigationDestination _navDestination(
      NavScreens screen,
      IconData icon,
      String labelKey,
      ) {
    return NavigationDestination(
      icon: Icon(icon),
      label: AppLocale.getValue(labelKey).getString(context),
    );
  }
}
