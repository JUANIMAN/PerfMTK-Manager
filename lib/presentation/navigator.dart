import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/providers/app_profile_provider.dart';
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
      ref.read(appProfileProvider.notifier).initialize();
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

  @override
  Widget build(BuildContext context) {
    // Leer el estado de visibilidad
    final showAppProfiles = ref.watch(appProfileVisibilityProvider);

    if (_currentScreen == NavScreens.appProfiles && !showAppProfiles) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentScreen = NavScreens.profiles);
        }
      });
    }

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
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _getSelectedIndex(showAppProfiles),
        children: [
          const ProfilesScreen(),
          if (showAppProfiles) const AppProfilesScreen(),
          const ThermalScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(showAppProfiles),
    );
  }

  Widget _buildBottomNavigationBar(bool showAppProfiles) {
    final destinations = <NavigationDestination>[
      _buildNavigationDestination(
        NavScreens.profiles,
        Icons.tune,
        'profiles',
      ),
      if (showAppProfiles)
        _buildNavigationDestination(
          NavScreens.appProfiles,
          Icons.apps,
          'appProfiles',
        ),
      _buildNavigationDestination(
        NavScreens.thermal,
        Icons.thermostat,
        'thermal',
      ),
    ];

    return Container(
      margin: AppConstants.paddingNormal,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: NavigationBar(
          selectedIndex: _getSelectedIndex(showAppProfiles),
          onDestinationSelected: (int index) {
            HapticFeedback.mediumImpact();
            setState(() {
              _currentScreen = _getScreenFromIndex(index, showAppProfiles);
            });
          },
          destinations: destinations,
          animationDuration: AppConstants.animationNormal,
        ),
      ),
    );
  }

  int _getSelectedIndex(bool showAppProfiles) {
    if (!showAppProfiles) {
      return _currentScreen == NavScreens.profiles ? 0 : 1;
    }
    return _currentScreen.index;
  }

  NavScreens _getScreenFromIndex(int index, bool showAppProfiles) {
    if (!showAppProfiles) {
      return index == 0 ? NavScreens.profiles : NavScreens.thermal;
    }
    return NavScreens.values[index];
  }

  NavigationDestination _buildNavigationDestination(
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
