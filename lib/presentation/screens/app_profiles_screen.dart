import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/providers/app_profile_provider.dart';
import 'package:manager/presentation/widgets/app_profile_item.dart';
import 'package:manager/config/app_constants.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AppProfilesScreen extends ConsumerStatefulWidget {
  const AppProfilesScreen({super.key});

  @override
  ConsumerState<AppProfilesScreen> createState() => _AppProfilesScreenState();
}

class _AppProfilesScreenState extends ConsumerState<AppProfilesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  AppFilterType _selectedFilter = AppFilterType.all;
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.offset >= 300 && !_showBackToTopButton) {
      setState(() => _showBackToTopButton = true);
    } else if (_scrollController.offset < 300 && _showBackToTopButton) {
      setState(() => _showBackToTopButton = false);
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
    final appProfileState = ref.watch(appProfileProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchAndFilterBar(),
          Expanded(
            child: appProfileState.when(
              data: (state) => _buildAppsList(state),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorView(error),
            ),
          ),
        ],
      ),
      floatingActionButton: _showBackToTopButton
          ? FloatingActionButton.small(
        onPressed: _scrollToTop,
        child: const Icon(Icons.arrow_upward),
      )
          : null,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing16,
        AppConstants.spacing16,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocale.titleAppProfiles.getString(context),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            AppLocale.appProfilesDescription.getString(context),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.subtle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    final appProfileState = ref.watch(appProfileProvider);
    final includeSystemApps = appProfileState.value?.includeSystemApps ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing16,
        AppConstants.spacing16,
        AppConstants.spacing8,
      ),
      child: Column(
        children: [
          TextField(
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Toggle para apps del sistema
          IgnorePointer(
            ignoring: appProfileState.isLoading,
            child: AnimatedOpacity(
              duration: AppConstants.animationFast,
              opacity: appProfileState.isLoading ? AppConstants.opacityDisabled : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing16,
                  vertical: AppConstants.spacing12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.disabled,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      size: AppConstants.iconSizeSmall,
                      color: includeSystemApps
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocale.includeSystemApps.getString(context),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocale.includeSystemAppsDesc.getString(context),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: includeSystemApps,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref.read(appProfileProvider.notifier).toggleSystemApps(value);
                      },
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      inactiveThumbColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spacing16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  AppFilterType.all,
                  AppLocale.allApps.getString(context),
                  Icons.apps,
                ),
                const SizedBox(width: AppConstants.spacing8),
                _buildFilterChip(
                  AppFilterType.configured,
                  AppLocale.configuredApps.getString(context),
                  Icons.check_circle_outline,
                ),
                const SizedBox(width: AppConstants.spacing8),
                _buildFilterChip(
                  AppFilterType.notConfigured,
                  AppLocale.notConfiguredApps.getString(context),
                  Icons.pending_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      AppFilterType filterType, String label, IconData icon) {
    final isSelected = _selectedFilter == filterType;

    return FilterChip(
      selected: isSelected,
      showCheckmark: false,
      avatar: Icon(
        icon,
        size: AppConstants.iconSizeSmall,
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.primary,
      ),
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor.border,
        ),
      ),
      onSelected: (selected) {
        setState(() => _selectedFilter = filterType);
        HapticFeedback.lightImpact();
      },
    );
  }

  Widget _buildAppsList(AppProfileState state) {
    var filteredApps = state.appProfiles;

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filteredApps = filteredApps.where((app) {
        return app.appInfo.name.toLowerCase().contains(lowerQuery) ||
            app.appInfo.packageName.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Filtrar por categoría
    if (_selectedFilter == AppFilterType.configured) {
      filteredApps = filteredApps.where((app) => app.isConfigured).toList();
    } else if (_selectedFilter == AppFilterType.notConfigured) {
      filteredApps = filteredApps.where((app) => !app.isConfigured).toList();
    }

    if (filteredApps.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(appProfileProvider.notifier).reloadInstalledApps(),
      child: AnimationLimiter(
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: AppConstants.paddingHorizontal,
          itemCount: filteredApps.length + 1,
          itemBuilder: (context, index) {
            if (index == filteredApps.length) {
              return const SizedBox(height: AppConstants.spacing80);
            }

            final appProfile = filteredApps[index];

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50,
                child: FadeInAnimation(
                  child: AppProfileItem(
                    key: ValueKey(appProfile.appInfo.packageName),
                    app: appProfile.appInfo,
                    currentProfile: appProfile.assignedProfile,
                    isSystemApp: appProfile.appInfo.isSystemApp,
                    onProfileSelected: (profile) {
                      ref.read(appProfileProvider.notifier).setAppProfile(
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.app_blocking,
            size: 64,
            color: Theme.of(context).colorScheme.primary.disabled,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            AppLocale.errorLoadingApps.getString(context),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppConstants.spacing8),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text(AppLocale.retry.getString(context)),
            onPressed: () =>
                ref.read(appProfileProvider.notifier).initialize(),
          ),
        ],
      ),
    );
  }

  void _showProfileChangedSnackbar(
      String appName,
      ProfileType? newProfile,
      ) {
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
              .replaceAll('{profile}', _getProfileName(newProfile.value)),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getProfileName(String profileKey) {
    switch (profileKey) {
      case 'performance':
        return AppLocale.performance.getString(context);
      case 'balanced':
        return AppLocale.balanced.getString(context);
      case 'powersave':
        return AppLocale.powersave.getString(context);
      case 'powersave+':
        return AppLocale.powersavePlus.getString(context);
      default:
        return profileKey;
    }
  }
}