import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/providers/app_profile_provider.dart';
import 'package:manager/presentation/widgets/app_profile_item.dart';
import 'package:manager/presentation/widgets/profile_utils.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/presentation/widgets/custom_selection_tile.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AppProfilesScreen extends ConsumerStatefulWidget {
  const AppProfilesScreen({super.key});

  @override
  ConsumerState<AppProfilesScreen> createState() => _AppProfilesScreenState();
}

class _AppProfilesScreenState extends ConsumerState<AppProfilesScreen>
    with SingleTickerProviderStateMixin, EntryAnimationMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  AppFilterType _selectedFilter = AppFilterType.all;
  bool _showBackToTopButton = false;

  // Daemon settings collapsed by default
  bool _daemonSettingsExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    initEntryAnimation();
  }

  @override
  void dispose() {
    disposeEntryAnimation();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset >= 300;
    if (shouldShow != _showBackToTopButton) {
      setState(() => _showBackToTopButton = shouldShow);
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
      body: buildWithEntryAnimation(
        Column(
          children: [
            // ── Fixed top section (header + search + filters) ─────────────────
            appProfileAsync.when(
              data: (state) => _buildFixedTop(state),
              loading: () => _buildFixedTop(null),
              error: (_, _s) => _buildFixedTop(null),
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
      ),
      floatingActionButton: _showBackToTopButton
          ? Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.small(
          heroTag: 'app_profiles_top',
          onPressed: _scrollToTop,
          child: const Icon(Icons.arrow_upward_rounded),
        ),
      )
          : null,
    );
  }

  // ── Fixed top: title + daemon settings chip + search + filters ────────────
  Widget _buildFixedTop(AppProfileState? state) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row + daemon settings icon
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              AppConstants.spacing16,
              AppConstants.spacing8,
              AppConstants.spacing8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocale.titleAppProfiles.getString(context),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocale.appProfilesDescription.getString(context),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                // Daemon settings icon button
                if (state != null)
                  Tooltip(
                    message: AppLocale.daemonSettings.getString(context),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() =>
                              _daemonSettingsExpanded = !_daemonSettingsExpanded);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.spacing8),
                          child: AnimatedRotation(
                            duration: AppConstants.animationNormal,
                            turns: _daemonSettingsExpanded ? 0.5 : 0,
                            child: Icon(
                              Icons.tune_rounded,
                              color: _daemonSettingsExpanded
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
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
                  ? _buildDaemonSettingsCard(state)
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
            child: _buildSearchField(),
          ),

          // ── Filter chips ───────────────────────────────────────────────────
          if (state != null) _buildFilterRow(state),

          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: AppLocale.searchApps.getString(context),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                  HapticFeedback.lightImpact();
                },
              )
            : null,
        filled: true,
        fillColor: theme.brightness == Brightness.light
            ? cs.surfaceContainerHighest
            : cs.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(
            color: cs.primary,
            width: 1.5,
          ),
        ),
      ),
      onChanged: (value) => setState(() => _searchQuery = value),
      style: theme.textTheme.bodyLarge,
    );
  }

  Widget _buildFilterRow(AppProfileState state) {
    final isLoading = ref.watch(appProfileProvider).isLoading;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing4,
        AppConstants.spacing16,
        AppConstants.spacing8,
      ),
      child: Row(
        children: [
          // Filter chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    AppFilterType.all,
                    AppLocale.allApps.getString(context),
                    Icons.apps_rounded,
                  ),
                  const SizedBox(width: AppConstants.spacing6),
                  _buildFilterChip(
                    AppFilterType.configured,
                    AppLocale.configuredApps.getString(context),
                    Icons.check_circle_outline_rounded,
                  ),
                  const SizedBox(width: AppConstants.spacing6),
                  _buildFilterChip(
                    AppFilterType.notConfigured,
                    AppLocale.notConfiguredApps.getString(context),
                    Icons.pending_outlined,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: AppConstants.spacing8),

          // System apps toggle — compact icon button
          Tooltip(
            message: AppLocale.includeSystemApps.getString(context),
            child: AnimatedContainer(
              duration: AppConstants.animationFast,
              decoration: BoxDecoration(
                color: state.includeSystemApps
                    ? theme.colorScheme.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(
                  color: state.includeSystemApps
                      ? theme.colorScheme.primary.withValues(alpha: 0.4)
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              child: IgnorePointer(
                ignoring: isLoading,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(appProfileProvider.notifier)
                        .toggleSystemApps(!state.includeSystemApps);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacing6),
                    child: Icon(
                      Icons.security_rounded,
                      size: AppConstants.iconSizeMedium,
                      color: state.includeSystemApps
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(AppFilterType filterType, String label, IconData icon) {
    final isSelected = _selectedFilter == filterType;
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = filterType);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing10,
          vertical: AppConstants.spacing6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppConstants.spacing4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Daemon Settings card (compact, collapsible) ───────────────────────────
  Widget _buildDaemonSettingsCard(AppProfileState state) {
    final isConfigured = state.configExists;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        0,
        AppConstants.spacing16,
        AppConstants.spacing8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: IgnorePointer(
          ignoring: !isConfigured,
          child: AnimatedOpacity(
            duration: AppConstants.animationFast,
            opacity: isConfigured ? 1.0 : AppConstants.opacityDisabled,
            child: Column(
              children: [
                _buildScreenOffRow(state),
                Divider(
                  height: 1,
                  indent: AppConstants.spacing16,
                  endIndent: AppConstants.spacing16,
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
                _buildDebounceRow(state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreenOffRow(AppProfileState state) {
    final cs = Theme.of(context).colorScheme;
    final color = ProfileUtils.colorFor(state.screenOffProfile);
    final icon = ProfileUtils.iconFor(state.screenOffProfile);

    return InkWell(
      onTap: state.configExists
          ? () {
              HapticFeedback.lightImpact();
              _showScreenOffProfileSheet(state.screenOffProfile);
            }
          : null,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusXLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing12,
        ),
        child: Row(
          children: [
            Icon(Icons.bedtime_rounded, size: AppConstants.iconSizeMedium, color: cs.primary),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocale.screenOffProfile.getString(context),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    AppLocale.screenOffProfileDesc.getString(context),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 12, color: color),
                  const SizedBox(width: 4),
                  Text(
                    state.screenOffProfile.displayName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacing4),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant, size: AppConstants.iconSizeMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildDebounceRow(AppProfileState state) {
    final cs = Theme.of(context).colorScheme;
    final debounce = state.appDebounceMs;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing10,
        AppConstants.spacing16,
        AppConstants.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined,
                  size: AppConstants.iconSizeMedium, color: cs.primary),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.appDebounceMs.getString(context),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      AppLocale.appDebounceMsDesc.getString(context),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '${debounce}ms',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: debounce.toDouble(),
              min: 500,
              max: 10000,
              divisions: 38,
              onChanged: (value) {
                final snapped = (value / 250).round() * 250;
                ref.read(appProfileProvider.notifier).setDebounceMs(snapped);
              },
              onChangeEnd: (_) => HapticFeedback.selectionClick(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Scrollable app list ───────────────────────────────────────────────────
  Widget _buildAppList(AppProfileState state) {
    var filteredApps = state.appProfiles;

    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filteredApps = filteredApps.where((app) {
        return app.appInfo.name.toLowerCase().contains(lowerQuery) ||
            app.appInfo.packageName.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    if (_selectedFilter == AppFilterType.configured) {
      filteredApps = filteredApps.where((app) => app.isConfigured).toList();
    } else if (_selectedFilter == AppFilterType.notConfigured) {
      filteredApps = filteredApps.where((app) => !app.isConfigured).toList();
    }

    if (filteredApps.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(appProfileProvider.notifier).reloadInstalledApps(),
      child: AnimationLimiter(
        child: ListView.builder(
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
          itemCount: filteredApps.length,
          itemBuilder: (context, index) {
            final appProfile = filteredApps[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 300),
              child: SlideAnimation(
                verticalOffset: 30,
                child: FadeInAnimation(
                  child: AppProfileItem(
                    key: ValueKey(appProfile.appInfo.packageName),
                    app: appProfile.appInfo,
                    currentProfile: appProfile.assignedProfile,
                    isSystemApp: appProfile.appInfo.isSystemApp,
                    onProfileSelected: (profile) {
                      ref
                          .read(appProfileProvider.notifier)
                          .setAppProfile(
                            appProfile.appInfo.packageName,
                            profile,
                          );
                      _showProfileChangedSnackbar(
                        appProfile.appInfo.name,
                        profile,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Screen-off profile picker ─────────────────────────────────────────────
  void _showScreenOffProfileSheet(ProfileType current) {
    final profiles = ProfileType.values;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusXLarge),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppConstants.spacing12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing16),
                Padding(
                  padding: AppConstants.paddingHorizontal,
                  child: Row(
                    children: [
                      Icon(Icons.bedtime_rounded,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: AppConstants.spacing12),
                      Text(
                        AppLocale.screenOffProfile.getString(context),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacing12),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                const SizedBox(height: AppConstants.spacing8),
                ...profiles.map((profile) {
                  final isSelected = profile == current;
                  final color = ProfileUtils.colorFor(profile);
                  final icon = ProfileUtils.iconFor(profile);

                  return SelectionTile(
                    icon: icon,
                    iconColor: color,
                    title: profile.displayName,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(appProfileProvider.notifier)
                          .setScreenOffProfile(profile);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
                const SizedBox(height: AppConstants.spacing16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Empty / Error states ──────────────────────────────────────────────────
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
                ? AppLocale.noSearchResults.getString(context)
                : AppLocale.noAppsFound.getString(context),
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
              AppLocale.errorLoadingApps.getString(context),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.spacing16),
            FilledButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocale.retry.getString(context)),
              onPressed: () => ref.refresh(appProfileProvider),
            ),
          ],
        ),
      ),
    );
  }

  // ── Snackbar ──────────────────────────────────────────────────────────────
  void _showProfileChangedSnackbar(String appName, ProfileType? newProfile) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newProfile == null
              ? AppLocale.profileReset
                  .getString(context)
                  .replaceAll('{app}', appName)
              : AppLocale.profileSet
                  .getString(context)
                  .replaceAll('{app}', appName)
                  .replaceAll('{profile}', newProfile.displayName),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}