import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/theme_provider.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/views/profiles.dart';
import 'package:manager/views/thermal.dart';
import 'package:manager/utils/update_checker.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum NavScreens { profiles, thermal }

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
    _checkForUpdates();
    super.initState();
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

  final Map<NavScreens, Widget> _screens = {
    NavScreens.profiles: const Profiles(),
    NavScreens.thermal: const Thermal(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PerfMTK Manager'),
        actions: const [
          ThemeSwitcher(),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(microseconds: 300),
        child: _screens[_currentScreen],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: NavigationBar(
          selectedIndex: _currentScreen.index,
          onDestinationSelected: (int index) {
            setState(() {
              _currentScreen = NavScreens.values[index];
            });
          },
          destinations: [
            _buildNavigationDestination(NavScreens.profiles, Icons.tune, 'profiles'),
            _buildNavigationDestination(NavScreens.thermal, Icons.thermostat, 'thermal'),
          ],
          animationDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }

  NavigationDestination _buildNavigationDestination(NavScreens screen, IconData icon, String labelKey) {
    return NavigationDestination(
      icon: Icon(icon),
      label: AppLocale.getValue(labelKey).getString(context),
    );
  }
}
