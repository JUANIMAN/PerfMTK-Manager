import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:manager/data/models/app_profile.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/repositories/config_repository.dart';
import 'package:manager/presentation/providers/app_profile_visibility_provider.dart';

// Provider del repositorio
final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepositoryImpl();
});

// Provider del estado de la configuración
final appProfileProvider = StateNotifierProvider<AppProfileNotifier, AsyncValue<AppProfileState>>((ref) {
  return AppProfileNotifier(
    ref.read(configRepositoryProvider),
    ref.read(appProfileVisibilityProvider.notifier),
  );
});

class AppProfileState {
  final List<AppProfile> appProfiles;
  final ProfileType defaultProfile;
  final bool configExists;
  final bool includeSystemApps;

  const AppProfileState({
    required this.appProfiles,
    required this.defaultProfile,
    required this.configExists,
    this.includeSystemApps = false,
  });

  AppProfileState copyWith({
    List<AppProfile>? appProfiles,
    ProfileType? defaultProfile,
    bool? configExists,
    bool? includeSystemApps,
  }) {
    return AppProfileState(
      appProfiles: appProfiles ?? this.appProfiles,
      defaultProfile: defaultProfile ?? this.defaultProfile,
      configExists: configExists ?? this.configExists,
      includeSystemApps: includeSystemApps ?? this.includeSystemApps,
    );
  }

  // Estado inicial
  factory AppProfileState.initial() {
    return const AppProfileState(
      appProfiles: [],
      defaultProfile: ProfileType.balanced,
      configExists: false,
      includeSystemApps: false,
    );
  }
}

class AppProfileNotifier extends StateNotifier<AsyncValue<AppProfileState>> {
  final ConfigRepository _repository;
  final AppProfileVisibilityNotifier _visibilityNotifier;

  AppProfileNotifier(this._repository, this._visibilityNotifier)
      : super(const AsyncValue.loading()) {
    initialize();
  }

  /// Inicializa el estado cargando configuración y apps instaladas
  Future<void> initialize({bool isRefresh = false}) async {
    try {
      // Si es un refresh, no cambiar el estado a loading
      if (!isRefresh) {
        state = const AsyncValue.loading();
      }

      final currentIncludeSystemApps = state.value?.includeSystemApps ?? false;

      final configExists = await _repository.configExists();

      // Actualizar visibilidad basado en si existe config
      if (configExists) {
        await _visibilityNotifier.show();
      }

      final defaultProfile = configExists
          ? await _repository.getDefaultProfile()
          : ProfileType.balanced;

      final profileMap = configExists
          ? await _repository.loadAppProfiles()
          : <String, ProfileType>{};

      final installedApps = await InstalledApps.getInstalledApps(
        withIcon: true,
        excludeSystemApps: !currentIncludeSystemApps,
      );

      final appProfiles = installedApps.map((app) {
        return AppProfile(
          appInfo: app,
          assignedProfile: profileMap[app.packageName],
        );
      }).toList()..sort((a, b) => a.appInfo.name.compareTo(b.appInfo.name));

      state = AsyncValue.data(AppProfileState(
        appProfiles: appProfiles,
        defaultProfile: defaultProfile,
        configExists: configExists,
        includeSystemApps: currentIncludeSystemApps,
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Actualiza el perfil de una app específica
  Future<void> setAppProfile(String packageName, ProfileType? profile) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      // Construir el mapa actualizado
      final updatedProfiles = <String, ProfileType>{};
      for (final app in currentState.appProfiles) {
        if (app.appInfo.packageName == packageName) {
          if (profile != null) {
            updatedProfiles[packageName] = profile;
          }
        } else if (app.assignedProfile != null) {
          updatedProfiles[app.appInfo.packageName] = app.assignedProfile!;
        }
      }

      // Guardar en disco
      await _repository.saveAppProfiles(updatedProfiles, currentState.defaultProfile);

      // Actualizar visibilidad
      await _visibilityNotifier.show();

      // Recargar desde archivo
      await initialize(isRefresh: true);

    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      // Recargar el estado correcto
      await initialize();
    }
  }

  /// Actualiza el perfil por defecto
  Future<void> setDefaultProfile(ProfileType profile) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final profileMap = <String, ProfileType>{};
      for (final app in currentState.appProfiles) {
        if (app.assignedProfile != null) {
          profileMap[app.appInfo.packageName] = app.assignedProfile!;
        }
      }

      // Guardar
      await _repository.saveAppProfiles(profileMap, profile);

      // Recargar desde archivo
      await initialize(isRefresh: true);

    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      await initialize();
    }
  }

  /// Toggle para incluir/excluir apps del sistema
  Future<void> toggleSystemApps(bool include) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      state = AsyncValue.data(currentState.copyWith(
        includeSystemApps: include,
      ));

      state = const AsyncValue.loading();

      final profileMap = await _repository.loadAppProfiles();

      final installedApps = await InstalledApps.getInstalledApps(
        withIcon: true,
        excludeSystemApps: !include,
      );

      final appProfiles = installedApps.map((app) {
        return AppProfile(
          appInfo: app,
          assignedProfile: profileMap[app.packageName],
        );
      }).toList()..sort((a, b) => a.appInfo.name.compareTo(b.appInfo.name));

      state = AsyncValue.data(currentState.copyWith(
        appProfiles: appProfiles,
        includeSystemApps: include,
      ));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Recarga las apps instaladas
  Future<void> reloadInstalledApps() async {
    await initialize(isRefresh: true);
  }

  /// Eliminar la configuración y ocultar la pestaña
  Future<void> deleteConfiguration() async {
    try {
      await _repository.deleteConfig();
      await _visibilityNotifier.hide();
      await initialize();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

enum AppFilterType {
  all,
  configured,
  notConfigured,
}
