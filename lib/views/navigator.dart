import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/services/app_profile_service.dart';
import 'package:manager/views/app_profiles.dart';
import 'package:manager/views/profiles.dart';
import 'package:manager/views/settings_screen.dart';
import 'package:manager/views/thermal.dart';
import 'package:manager/utils/update_checker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';

enum NavScreens { profiles, appProfiles, thermal }

class Navegador extends StatefulWidget {
  const Navegador({super.key});

  @override
  State<Navegador> createState() => _NavegadorState();
}

class _NavegadorState extends State<Navegador> {
  final FlutterLocalization localization = FlutterLocalization.instance;
  NavScreens _currentScreen = NavScreens.profiles;

  @override
  void initState() {
    super.initState();
    _initializeAppProfileService();
    _checkForUpdates();
  }

  Future<void> _initializeAppProfileService() async {
    final appProfileService = context.read<AppProfileService>();
    await appProfileService.initialize();
  }

  Future<void> _checkForUpdates() async {
    final packageInfo = await PackageInfo.fromPlatform();

    final updateChecker = UpdateChecker(
      owner: 'JUANIMAN',
      repo: 'PerfMTK-Manager',
      currentVersion: packageInfo.version,
      currentLanguage: localization.currentLocale.localeIdentifier,
    );

    await updateChecker.checkForUpdates(context);
  }

  Map<NavScreens, Widget> get _screens => {
    NavScreens.profiles: const Profiles(),
    NavScreens.appProfiles: const AppProfiles(),
    NavScreens.thermal: const Thermal(),
  };

  @override
  Widget build(BuildContext context) {
    final appProfileService = context.watch<AppProfileService>();
    final showAppProfiles = appProfileService.configExists;

    if (_currentScreen == NavScreens.appProfiles && !showAppProfiles) {
      _currentScreen = NavScreens.profiles;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PerfMTK Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: _screens[_currentScreen],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(showAppProfiles),
    );
  }

  Widget _buildBottomNavigationBar(bool showAppProfiles) {
    final destinations = [
      _buildNavigationDestination(NavScreens.profiles, Icons.tune, 'profiles'),
      _buildNavigationDestination(NavScreens.thermal, Icons.thermostat, 'thermal'),
    ];

    if (showAppProfiles) {
      destinations.insert(1, _buildNavigationDestination(NavScreens.appProfiles, Icons.apps, 'appProfiles'));
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: NavigationBar(
          selectedIndex: _getSelectedIndex(showAppProfiles),
          onDestinationSelected: (int index) {
            HapticFeedback.mediumImpact();
            setState(() {
              if (showAppProfiles) {
                _currentScreen = NavScreens.values[index];
              } else {
                _currentScreen = index == 0 ? NavScreens.profiles : NavScreens.thermal;
              }
            });
          },
          destinations: destinations,
          animationDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }

  int _getSelectedIndex(bool showAppProfiles) {
    if (showAppProfiles) {
      return _currentScreen.index;
    } else {
      return _currentScreen == NavScreens.profiles ? 0 : 1;
    }
  }

  NavigationDestination _buildNavigationDestination(NavScreens screen, IconData icon, String labelKey) {
    return NavigationDestination(
      icon: Icon(icon),
      label: AppLocale.getValue(labelKey).getString(context),
    );
  }
}

