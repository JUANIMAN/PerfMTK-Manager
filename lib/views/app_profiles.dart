import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/services/app_profile_service.dart';
import 'package:manager/widgets/app_profile_item.dart';
import 'package:provider/provider.dart';
import 'package:installed_apps/app_info.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AppProfiles extends StatefulWidget {
  const AppProfiles({super.key});

  @override
  State<AppProfiles> createState() => _AppProfilesState();
}

class _AppProfilesState extends State<AppProfiles> with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // Filtro actual: 'all', 'configured', 'notConfigured'
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  // Para mantener el estado cuando se cambia de pestaña
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Configurar el listener para el botón de volver arriba
    _scrollController.addListener(() {
      setState(() {
        _showBackToTopButton = _scrollController.offset >= 300;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool refresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar perfiles de aplicaciones desde AppProfileService
      final appProfileService = context.read<AppProfileService>();
      await appProfileService.loadInstalledApps(forceReload: refresh);
      if (!appProfileService.isInitialized) appProfileService.loadAppProfiles();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Mostrar un snackbar para el error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocale.errorLoadingApps.getString(context)),
            action: SnackBarAction(
              label: AppLocale.retry.getString(context),
              onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    return _loadData(refresh: true);
  }

  // Filtrar apps según el criterio seleccionado
  List<AppInfo> get _filteredApps {
    final appProfileService = context.read<AppProfileService>();
    List<AppInfo> filteredList = appProfileService.installedApps;

    // Primero filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList.where((app) =>
      app.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          app.packageName.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Luego aplicar filtro de categoría
    if (_selectedFilter == 'configured') {
      filteredList = filteredList.where((app) =>
      appProfileService.getAppProfile(app.packageName).isNotEmpty
      ).toList();
    } else if (_selectedFilter == 'notConfigured') {
      filteredList = filteredList.where((app) =>
      appProfileService.getAppProfile(app.packageName).isEmpty
      ).toList();
    }

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchAndFilterBar(),
          _isLoading
              ? const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
              : _buildAppsList()
        ],
      ),
      floatingActionButton: _showBackToTopButton
          ? FloatingActionButton(
        mini: true,
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          HapticFeedback.lightImpact();
        },
        child: const Icon(Icons.arrow_upward),
      )
          : null,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocale.titleAppProfiles.getString(context),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocale.appProfilesDescription.getString(context),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de búsqueda
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocale.searchApps.getString(context),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    HapticFeedback.lightImpact();
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Fila de filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', AppLocale.allApps.getString(context), Icons.apps),
                const SizedBox(width: 8),
                _buildFilterChip('configured', AppLocale.configuredApps.getString(context), Icons.check_circle_outline),
                const SizedBox(width: 8),
                _buildFilterChip('notConfigured', AppLocale.notConfiguredApps.getString(context), Icons.pending_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      selected: isSelected,
      showCheckmark: false,
      avatar: Icon(
        icon,
        size: 18,
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
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        HapticFeedback.lightImpact();
      },
    );
  }

  Widget _buildAppsList({Key? key}) {
    final filteredApps = _filteredApps;
    final appProfileService = context.read<AppProfileService>();

    return Expanded(
      key: key,
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: filteredApps.isEmpty
            ? _buildEmptyState()
            : AnimationLimiter(
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: filteredApps.length + 1, // +1 para el espacio adicional al final
            itemBuilder: (context, index) {
              if (index == filteredApps.length) {
                return const SizedBox(height: 80); // Espacio adicional al final
              }

              final app = filteredApps[index];
              final currentProfile = appProfileService.getAppProfile(app.packageName);

              // Usar AnimationConfiguration para una animación de entrada más suave
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: AppProfileItem(
                      app: app,
                      currentProfile: currentProfile,
                      onProfileSelected: (profile) {
                        appProfileService.setAppProfile(app.packageName, profile);
                        setState(() {}); // Actualiza la UI

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              profile.isEmpty
                                  ? AppLocale.profileReset.getString(context).replaceAll('{app}', app.name)
                                  : AppLocale.profileSet.getString(context)
                                  .replaceAll('{app}', app.name)
                                  .replaceAll('{profile}', _getProfileName(profile, context)),
                            ),
                            duration: const Duration(seconds: 5),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: AppLocale.undo.getString(context),
                              onPressed: () {
                                // Revertir el cambio
                                appProfileService.setAppProfile(app.packageName, currentProfile);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
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
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? AppLocale.noSearchResults.getString(context)
                : AppLocale.noAppsFound.getString(context),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (_searchQuery.isNotEmpty)
            ElevatedButton.icon(
              icon: const Icon(Icons.clear),
              label: Text(AppLocale.clearSearch.getString(context)),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
                HapticFeedback.mediumImpact();
              },
            ),
        ],
      ),
    );
  }

  String _getProfileName(String profileKey, BuildContext context) {
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