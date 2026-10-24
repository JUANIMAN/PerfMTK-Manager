import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/app_profiles/presentation/app_profile_visibility_provider.dart';
import 'package:manager/features/system/presentation/system_provider.dart';
import 'package:manager/features/app_profiles/presentation/app_profiles_screen.dart';
import 'package:manager/features/battery/presentation/battery_screen.dart';
import 'package:manager/features/perf_config/presentation/perf_config_screen.dart';
import 'package:manager/features/profiles/presentation/profiles_screen.dart';
import 'package:manager/features/settings/presentation/settings_screen.dart';
import 'package:manager/features/backup/presentation/backup_screen.dart';
import 'package:manager/core/utils/update_checker.dart';
import 'package:manager/core/design/app_constants.dart';
import 'package:manager/app/shell/fade_through_tab_body.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum NavScreens { profiles, battery, appProfiles, perfConfig }

class AppNavigator extends ConsumerStatefulWidget {
  const AppNavigator({super.key});

  @override
  ConsumerState<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends ConsumerState<AppNavigator>
    with WidgetsBindingObserver {
  NavScreens _currentScreen = NavScreens.profiles;
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
        currentLanguage: ref.read(localeProvider).languageCode,
      );
      await updateChecker.checkForUpdates(context);
    } catch (_) {
      // Update checks must never interrupt the main application flow.
    }
  }

  /// Ordered list of screens currently visible in the nav bar.
  List<NavScreens> _screenList(bool showAppProfiles) => [
    NavScreens.profiles,
    NavScreens.battery,
    if (showAppProfiles) NavScreens.appProfiles,
    NavScreens.perfConfig,
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
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: Text(
            switch (currentScreen) {
              NavScreens.profiles => 'PerfMTK Manager',
              NavScreens.battery => context.l10n.titleBattery,
              NavScreens.appProfiles => context.l10n.appProfiles,
              NavScreens.perfConfig => context.l10n.perfConfig,
            },
            key: ValueKey(currentScreen),
          ),
        ),
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
          if (currentScreen == NavScreens.perfConfig)
            IconButton(
              icon: const Icon(Icons.backup_rounded),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BackupScreen()),
                );
              },
              tooltip: context.l10n.backupManager,
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
    return FadeThroughTabBody(
      currentScreen: currentScreen,
      showAppProfiles: showAppProfiles,
      screenBuilder: _screenFor,
    );
  }

  Widget _screenFor(NavScreens screen) => switch (screen) {
    NavScreens.profiles => const ProfilesScreen(),
    NavScreens.battery => const BatteryScreen(),
    NavScreens.appProfiles => const AppProfilesScreen(),
    NavScreens.perfConfig => const PerfConfigScreen(),
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
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
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
    final l = context.l10n;
    final (selectedIcon, unselectedIcon, label) = switch (screen) {
      NavScreens.profiles => (
        Icons.tune_rounded,
        Icons.tune,
        l.profiles,
      ),
      NavScreens.battery => (
        Icons.battery_charging_full_rounded,
        Icons.battery_charging_full_outlined,
        l.battery,
      ),
      NavScreens.appProfiles => (
        Icons.apps_rounded,
        Icons.apps_outlined,
        l.appProfiles,
      ),
      NavScreens.perfConfig => (
        Icons.speed_rounded,
        Icons.speed_outlined,
        l.perfConfig,
      ),
    };

    final accentColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB);

    return InkWell(
      onTap: () {
        if (!isSelected) {
          HapticFeedback.lightImpact();
          setState(() {
            _currentScreen = screen;
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
