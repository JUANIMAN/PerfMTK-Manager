import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/providers/app_profile_visibility_provider.dart';
import 'package:manager/presentation/providers/system_provider.dart';
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

class _AppNavigatorState extends ConsumerState<AppNavigator>
    with WidgetsBindingObserver {
  final FlutterLocalization localization = FlutterLocalization.instance;
  NavScreens _currentScreen = NavScreens.profiles;
  final Set<NavScreens> _visitedScreens = {NavScreens.profiles};
  DateTime? _lastResumeRefresh;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final now = DateTime.now();
    final lastRefresh = _lastResumeRefresh;
    if (lastRefresh != null &&
        now.difference(lastRefresh) < const Duration(seconds: 2)) {
      return;
    }
    _lastResumeRefresh = now;

    if (ref.read(isChangingProfileProvider) ||
        ref.read(isChangingThermalProvider) ||
        ref.read(systemStateProvider).isLoading) {
      return;
    }
    ref.read(systemStateProvider.notifier).refresh();
  }

  Future<void> _checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      final updateChecker = UpdateChecker(
        owner: 'JUANIMAN',
        repo: 'PerfMTK-Manager',
        currentVersion: packageInfo.version,
        currentLanguage: localization.currentLocale?.languageCode ?? 'en',
      );
      await updateChecker.checkForUpdates(context);
    } catch (_) {
      // Update checks must never interrupt the main application flow.
    }
  }

  /// Ordered list of screens currently visible in the nav bar.
  List<NavScreens> _screenList(bool showAppProfiles) => [
    NavScreens.profiles,
    if (showAppProfiles) NavScreens.appProfiles,
    NavScreens.perfConfig,
    NavScreens.thermal,
  ];

  NavScreens _effectiveScreen(bool showAppProfiles) {
    final list = _screenList(showAppProfiles);
    return list.contains(_currentScreen) ? _currentScreen : NavScreens.profiles;
  }

  @override
  Widget build(BuildContext context) {
    final showAppProfiles =
        ref.watch(appProfileVisibilityProvider).value ?? false;
    final currentScreen = _effectiveScreen(showAppProfiles);

    final systemState = ref.watch(systemStateProvider).value;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final engineColor = isDark ? const Color(0xFF00E676) : const Color(0xFF0A8754);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('PerfMTK Manager'),
        actions: [
          if (systemState != null && systemState.fgEngine.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: engineColor.withValues(alpha: isDark ? 0.12 : 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: engineColor.withValues(alpha: isDark ? 0.35 : 0.40),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: engineColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: engineColor.withValues(alpha: 0.6),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      systemState.fgEngine.toLowerCase().contains('lsposed')
                          ? 'LSPosed'
                          : (systemState.fgEngine.toLowerCase().contains('cgroup')
                              ? 'cgroup'
                              : 'Poller'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: engineColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
      body: _buildBody(currentScreen, showAppProfiles),
      bottomNavigationBar: _buildNavBar(showAppProfiles),
    );
  }

  Widget _buildBody(NavScreens currentScreen, bool showAppProfiles) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final screen in NavScreens.values)
          if (_visitedScreens.contains(screen) &&
              (screen != NavScreens.appProfiles || showAppProfiles))
            Offstage(
              key: ValueKey(screen),
              offstage: screen != currentScreen,
              child: TickerMode(
                enabled: screen == currentScreen,
                child: _screenFor(screen),
              ),
            ),
      ],
    );
  }

  Widget _screenFor(NavScreens screen) => switch (screen) {
    NavScreens.profiles => const ProfilesScreen(),
    NavScreens.appProfiles => const AppProfilesScreen(),
    NavScreens.perfConfig => const PerfConfigScreen(),
    NavScreens.thermal => const ThermalScreen(),
  };

  Widget _buildNavBar(bool showAppProfiles) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screens = _screenList(showAppProfiles);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacing16,
          0,
          AppConstants.spacing16,
          AppConstants.spacing10,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161618).withValues(alpha: 0.65)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.16)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1.0,
                ),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                          spreadRadius: -2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.09),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                          spreadRadius: -1,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  for (int i = 0; i < screens.length; i++)
                    Expanded(
                      flex: screens[i] == _currentScreen ? 16 : 9,
                      child: _buildNavItem(screens[i], screens[i] == _currentScreen),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavScreens screen, bool isSelected) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final (selectedIcon, unselectedIcon, labelKey) = switch (screen) {
      NavScreens.profiles => (
        Icons.tune_rounded,
        Icons.tune,
        AppLocale.profiles,
      ),
      NavScreens.appProfiles => (
        Icons.apps_rounded,
        Icons.apps_outlined,
        AppLocale.appProfiles,
      ),
      NavScreens.perfConfig => (
        Icons.speed_rounded,
        Icons.speed_outlined,
        AppLocale.perfConfig,
      ),
      NavScreens.thermal => (
        Icons.thermostat_rounded,
        Icons.thermostat_outlined,
        AppLocale.thermal,
      ),
    };

    final accentColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB);
    final label = AppLocale.getValue(labelKey).getString(context);

    return InkWell(
      onTap: () {
        if (!isSelected) {
          HapticFeedback.selectionClick();
          setState(() {
            _currentScreen = screen;
            _visitedScreens.add(screen);
          });
        }
      },
      borderRadius: BorderRadius.circular(22),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: isSelected
              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: isSelected
              ? BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.16 : 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: accentColor.withValues(alpha: isDark ? 0.40 : 0.35),
                    width: 1.0,
                  ),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.22),
                            blurRadius: 10,
                            spreadRadius: 0.5,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected
                    ? accentColor
                    : (isDark
                        ? cs.onSurfaceVariant.withValues(alpha: 0.60)
                        : const Color(0xFF334155).withValues(alpha: 0.75)), // Slate 700
                size: isSelected ? 20 : 21,
              ),
              if (isSelected) ...[
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
