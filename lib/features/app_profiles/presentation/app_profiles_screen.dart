import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/providers/app_services_providers.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/features/app_profiles/data/app_profile.dart';
import 'package:manager/features/system/data/models/profile.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/app_profiles/presentation/app_profile_provider.dart';
import 'package:manager/features/perf_config/presentation/perf_config_provider.dart';
import 'package:manager/features/app_profiles/presentation/widgets/app_profile_item.dart';
import 'package:manager/features/app_profiles/presentation/widgets/app_filter_chips_bar.dart';
import 'package:manager/features/app_profiles/presentation/widgets/app_search_bar.dart';
import 'package:manager/features/app_profiles/presentation/widgets/daemon_settings_card.dart';
import 'package:manager/features/app_profiles/presentation/widgets/screen_off_profile_sheet.dart';
import 'package:manager/features/profiles/presentation/widgets/profile_utils.dart';

/// Screen for managing per-application performance profiles and daemon behavior.
class AppProfilesScreen extends ConsumerStatefulWidget {
  const AppProfilesScreen({super.key});

  @override
  ConsumerState<AppProfilesScreen> createState() => _AppProfilesScreenState();
}

class _AppProfilesScreenState extends ConsumerState<AppProfilesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showBackToTopButton = ValueNotifier<bool>(false);

  String _searchQuery = '';
  AppFilterType _selectedFilter = AppFilterType.all;
  bool _daemonSettingsExpanded = false;

  List<AppProfile>? _lastRawProfiles;
  String? _lastSearchQuery;
  AppFilterType? _lastSelectedFilter;
  List<AppProfile> _cachedFilteredApps = const [];
  int _cachedConfiguredCount = 0;

  void _updateFilterCache(List<AppProfile> rawProfiles) {
    if (identical(_lastRawProfiles, rawProfiles) &&
        _lastSearchQuery == _searchQuery &&
        _lastSelectedFilter == _selectedFilter) {
      return;
    }

    if (!identical(_lastRawProfiles, rawProfiles)) {
      _lastRawProfiles = rawProfiles;
      _cachedConfiguredCount = rawProfiles.where((a) => a.isConfigured).length;
    }

    _lastSearchQuery = _searchQuery;
    _lastSelectedFilter = _selectedFilter;

    var result = rawProfiles;
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      result = result.where((app) {
        return app.appInfo.name.toLowerCase().contains(lowerQuery) ||
            app.appInfo.packageName.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    if (_selectedFilter == AppFilterType.configured) {
      result = result.where((app) => app.isConfigured).toList();
    } else if (_selectedFilter == AppFilterType.notConfigured) {
      result = result.where((app) => !app.isConfigured).toList();
    }

    _cachedFilteredApps = result;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _showBackToTopButton.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset >= 300;
    if (_showBackToTopButton.value != shouldShow) {
      _showBackToTopButton.value = shouldShow;
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: AppConstants.animationNormal,
      curve: Curves.easeOut,
    );
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final appProfileAsync = ref.watch(appProfileProvider);

    return Scaffold(
      body: Column(
        children: [
          // ── Fixed top section (header + search + filters) ─────────────────
          appProfileAsync.when(
            data: (state) => _buildFixedTop(state),
            loading: () => _buildFixedTop(null),
            error: (_, _) => _buildFixedTop(null),
          ),

          // ── Scrollable app list ───────────────────────────────────────────
          Expanded(
            child: appProfileAsync.when(
              data: (state) => _buildAppList(state),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorView(error),
            ),
          ),
        ],
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTopButton,
        builder: (context, show, child) {
          if (!show) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: FloatingActionButton.small(
              heroTag: 'app_profiles_top',
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward_rounded),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFixedTop(AppProfileState? state) {
    final isConfigured = state?.configExists ?? false;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Title & daemon settings expand toggle ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              AppConstants.spacing8,
              AppConstants.spacing16,
              AppConstants.spacing6,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    context.l10n.appProfilesDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isConfigured)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Material(
                      color: _daemonSettingsExpanded
                          ? cs.primary.withValues(alpha: 0.16)
                          : (isDark
                              ? cs.surfaceContainerHigh.withValues(alpha: 0.40)
                              : cs.surfaceContainerHighest.withValues(alpha: 0.50)),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            _daemonSettingsExpanded = !_daemonSettingsExpanded;
                          });
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _daemonSettingsExpanded
                                  ? cs.primary.withValues(alpha: 0.50)
                                  : cs.outlineVariant.withValues(alpha: 0.25),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 14,
                                color: _daemonSettingsExpanded
                                    ? cs.primary
                                    : cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Daemon',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: _daemonSettingsExpanded
                                      ? cs.primary
                                      : cs.onSurfaceVariant,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 3),
                              AnimatedRotation(
                                turns: _daemonSettingsExpanded ? 0.5 : 0.0,
                                duration: AppConstants.animationFast,
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: _daemonSettingsExpanded
                                      ? cs.primary
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Daemon settings (collapsible, hidden by default) ───────────────
          if (state != null)
            AnimatedSize(
              duration: AppConstants.animationNormal,
              curve: Curves.easeOutCubic,
              child: _daemonSettingsExpanded
                  ? DaemonSettingsCard(
                      state: state,
                      onPickScreenOffProfile: () {
                        ScreenOffProfileSheet.show(
                          context,
                          currentProfile: state.screenOffProfile,
                          onProfileSelected: _setScreenOffProfile,
                        );
                      },
                      onCommitDebounce: _commitDebounce,
                    )
                  : const SizedBox.shrink(),
            ),

          // ── Search bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              AppConstants.spacing8,
              AppConstants.spacing16,
              AppConstants.spacing8,
            ),
            child: AppSearchBar(
              controller: _searchController,
              searchQuery: _searchQuery,
              onChanged: (val) => setState(() => _searchQuery = val),
              onClear: () => setState(() => _searchQuery = ''),
            ),
          ),

          // ── Filter chips ───────────────────────────────────────────────────
          if (state != null) ...[
            Builder(
              builder: (context) {
                _updateFilterCache(state.appProfiles);
                final totalCount = state.appProfiles.length;
                final configuredCount = _cachedConfiguredCount;
                final notConfiguredCount = totalCount - configuredCount;
                return AppFilterChipsBar(
                  selectedFilter: _selectedFilter,
                  includeSystemApps: state.includeSystemApps,
                  isLoading: ref.watch(appProfileProvider).isLoading,
                  totalCount: totalCount,
                  configuredCount: configuredCount,
                  notConfiguredCount: notConfiguredCount,
                  onFilterSelected: (f) => setState(() => _selectedFilter = f),
                  onToggleSystemApps: (inc) {
                    ref.read(appProfileProvider.notifier).toggleSystemApps(inc);
                  },
                );
              },
            ),
          ],

          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.18)),
        ],
      ),
    );
  }

  Widget _buildAppList(AppProfileState state) {
    _updateFilterCache(state.appProfiles);
    final filteredApps = _cachedFilteredApps;
    final hasHardwareBypass =
        ref.watch(deviceConfigProvider).value?.hasHardwareBypass ?? false;

    if (filteredApps.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(appIconCacheProvider).clear();
        await ref.read(appProfileProvider.notifier).reloadInstalledApps();
      },
      child: ListView.builder(
        key: const PageStorageKey('app_profiles_list_view'),
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacing16,
          AppConstants.spacing12,
          AppConstants.spacing16,
          AppConstants.spacing80 + AppConstants.spacing16,
        ),
        scrollCacheExtent: const ScrollCacheExtent.pixels(600),
        itemCount: filteredApps.length,
        itemBuilder: (context, index) {
          final appProfile = filteredApps[index];
          return AppProfileItem(
            key: ValueKey(appProfile.appInfo.packageName),
            app: appProfile.appInfo,
            currentProfile: appProfile.assignedProfile,
            currentDirectives: appProfile.directives,
            isSystemApp: appProfile.appInfo.isSystemApp,
            hasHardwareBypass: hasHardwareBypass,
            onProfileSelected: (profile, directives) => _setAppProfile(
              appProfile.appInfo.packageName,
              appProfile.appInfo.name,
              profile,
              directives: directives,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.apps_outage_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            _searchQuery.isNotEmpty
                ? context.l10n.noSearchResults
                : context.l10n.noAppsFound,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(Object error) {
    return Center(
      child: Padding(
        padding: AppConstants.paddingNormal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              context.l10n.errorLoadingApps,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.spacing16),
            FilledButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retry),
              onPressed: () => ref.refresh(appProfileProvider),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _commitDebounce(int value) async {
    try {
      await ref.read(appProfileProvider.notifier).setDebounceMs(value);
    } on Exception catch (_) {
      _showSaveError();
    }
  }

  Future<void> _setAppProfile(
    String packageName,
    String appName,
    ProfileType? profile, {
    AppDirectives? directives,
  }) async {
    try {
      await ref
          .read(appProfileProvider.notifier)
          .setAppProfile(packageName, profile, directives: directives);
      if (mounted) _showProfileChangedSnackbar(appName, profile);
    } on Exception catch (_) {
      _showSaveError();
    }
  }

  Future<void> _setScreenOffProfile(ProfileType profile) async {
    try {
      await ref.read(appProfileProvider.notifier).setScreenOffProfile(profile);
    } on Exception catch (_) {
      _showSaveError();
    }
  }

  void _showSaveError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.configSaveError),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
  }

  void _showProfileChangedSnackbar(String appName, ProfileType? newProfile) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newProfile == null
              ? context.l10n.profileReset(appName)
              : context.l10n.profileSet(
                  appName,
                  ProfileUtils.nameFor(context, newProfile),
                ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
