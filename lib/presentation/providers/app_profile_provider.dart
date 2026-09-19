import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:manager/data/models/app_profile.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/repositories/config_repository.dart';
import 'package:manager/presentation/providers/app_profile_visibility_provider.dart';
import 'package:manager/presentation/providers/config_repository_provider.dart';

class AppProfileState {
  final List<AppProfile> appProfiles;
  final ProfileType defaultProfile;
  final ProfileType screenOffProfile;
  final int appDebounceMs;
  final bool configExists;
  final bool includeSystemApps;

  const AppProfileState({
    required this.appProfiles,
    required this.defaultProfile,
    required this.screenOffProfile,
    required this.appDebounceMs,
    required this.configExists,
    this.includeSystemApps = false,
  });

  AppProfileState copyWith({
    List<AppProfile>? appProfiles,
    ProfileType? defaultProfile,
    ProfileType? screenOffProfile,
    int? appDebounceMs,
    bool? configExists,
    bool? includeSystemApps,
  }) {
    return AppProfileState(
      appProfiles: appProfiles ?? this.appProfiles,
      defaultProfile: defaultProfile ?? this.defaultProfile,
      screenOffProfile: screenOffProfile ?? this.screenOffProfile,
      appDebounceMs: appDebounceMs ?? this.appDebounceMs,
      configExists: configExists ?? this.configExists,
      includeSystemApps: includeSystemApps ?? this.includeSystemApps,
    );
  }
}

/// Provider del estado de la configuración de app profiles.
final appProfileProvider =
    AsyncNotifierProvider<AppProfileNotifier, AppProfileState>(
      AppProfileNotifier.new,
    );

class AppProfileNotifier extends AsyncNotifier<AppProfileState> {
  ConfigRepository get _repository => ref.read(configRepositoryProvider);

  @override
  Future<AppProfileState> build() => _load(includeSystemApps: false);

  Future<AppProfileState> _load({required bool includeSystemApps}) async {
    final config = await _repository.loadConfig();
    final configExists = config.existsOnDisk;

    if (configExists) {
      try {
        await ref.read(appProfileVisibilityProvider.notifier).show();
      } catch (_) {
        // Loading profiles should not fail because a preference write failed.
      }
    }

    final installedApps = await InstalledApps.getInstalledApps(
      withIcon: false,
      excludeSystemApps: !includeSystemApps,
    );

    final appProfiles =
        installedApps.map((app) {
          final entry = config.entries[app.packageName];
          return AppProfile(
            appInfo: app,
            assignedProfile: entry?.profile,
            directives: entry?.directives,
          );
        }).toList()..sort(
          (a, b) => a.appInfo.name.toLowerCase().compareTo(
            b.appInfo.name.toLowerCase(),
          ),
        );

    return AppProfileState(
      appProfiles: appProfiles,
      defaultProfile: config.defaultProfile,
      screenOffProfile: config.screenOffProfile,
      appDebounceMs: config.appDebounceMs,
      configExists: configExists,
      includeSystemApps: includeSystemApps,
    );
  }

  /// Actualiza el perfil de una app específica (optimistic update)
  Future<void> setAppProfile(
    String packageName,
    ProfileType? profile, {
    AppDirectives? directives,
  }) async {
    final current = state.requireValue;

    // Optimistic update: update in-memory list immediately
    final updatedList = current.appProfiles.map((app) {
      if (app.appInfo.packageName == packageName) {
        return profile == null
            ? app.copyWith(clearProfile: true, clearDirectives: true)
            : app.copyWith(
                assignedProfile: profile,
                directives: directives ?? app.directives,
              );
      }
      return app;
    }).toList();

    await _persistOptimistic(
      current.copyWith(appProfiles: updatedList, configExists: true),
      previous: current,
      ensureVisible: !current.configExists,
    );
  }

  /// Actualiza el perfil por defecto
  Future<void> setDefaultProfile(ProfileType profile) async {
    final current = state.requireValue;
    await _persistOptimistic(
      current.copyWith(defaultProfile: profile),
      previous: current,
    );
  }

  /// Actualiza el perfil de pantalla apagada
  Future<void> setScreenOffProfile(ProfileType profile) async {
    final current = state.requireValue;
    await _persistOptimistic(
      current.copyWith(screenOffProfile: profile),
      previous: current,
    );
  }

  /// Actualiza el debounce de cambio de app
  Future<void> setDebounceMs(int ms) async {
    final current = state.requireValue;
    final clamped = ms.clamp(500, 10000);
    await _persistOptimistic(
      current.copyWith(appDebounceMs: clamped),
      previous: current,
    );
  }

  Future<void> _persistOptimistic(
    AppProfileState next, {
    required AppProfileState previous,
    bool ensureVisible = false,
  }) async {
    state = AsyncData(next);

    try {
      await _repository.saveConfig(
        _entriesFor(next),
        next.defaultProfile,
        next.screenOffProfile,
        next.appDebounceMs,
      );
    } catch (error, stackTrace) {
      // Do not roll back a newer optimistic update that is already queued.
      if (identical(state.value, next)) state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }

    if (ensureVisible) {
      try {
        await ref.read(appProfileVisibilityProvider.notifier).show();
      } catch (_) {
        // The on-disk config remains authoritative for visibility on restart.
      }
    }
  }

  Map<String, AppProfileEntryData> _entriesFor(AppProfileState source) => {
    for (final app in source.appProfiles)
      if (app.assignedProfile != null)
        app.appInfo.packageName: AppProfileEntryData(
          profile: app.assignedProfile!,
          directives: app.directives ?? const AppDirectives(),
        ),
  };

  /// Cambia si se muestran apps del sistema y recarga la lista
  Future<void> toggleSystemApps(bool include) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(includeSystemApps: include));
  }

  /// Recarga la lista de apps instaladas
  Future<void> reloadInstalledApps() async {
    final include = state.value?.includeSystemApps ?? false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(includeSystemApps: include));
  }

  /// Elimina la configuración y oculta la pestaña App Profiles
  Future<void> deleteConfiguration() async {
    await _repository.deleteConfig();
    await ref.read(appProfileVisibilityProvider.notifier).hide();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(includeSystemApps: false));
  }

  /// Expone si existe configuración en disco
  bool get hasConfig => state.value?.configExists ?? false;
}

enum AppFilterType { all, configured, notConfigured }
