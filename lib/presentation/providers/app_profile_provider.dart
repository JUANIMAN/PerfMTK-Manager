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

  const AppProfileState({
    required this.appProfiles,
    required this.defaultProfile,
    required this.configExists,
  });

  AppProfileState copyWith({
    List<AppProfile>? appProfiles,
    ProfileType? defaultProfile,
    bool? configExists,
  }) {
    return AppProfileState(
      appProfiles: appProfiles ?? this.appProfiles,
      defaultProfile: defaultProfile ?? this.defaultProfile,
      configExists: configExists ?? this.configExists,
    );
  }
  
  // Estado inicial
  factory AppProfileState.initial() {
    return const AppProfileState(
      appProfiles: [],
      defaultProfile: ProfileType.balanced,
      configExists: false,
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

      final installedApps = await InstalledApps.getInstalledApps(withIcon: true);

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
      // Actualizar UI
      final updatedAppProfiles = currentState.appProfiles.map((app) {
        if (app.appInfo.packageName == packageName) {
          return profile == null
              ? app.copyWith(clearProfile: true)
              : app.copyWith(assignedProfile: profile);
        }
        return app;
      }).toList();

      state = AsyncValue.data(currentState.copyWith(
        appProfiles: updatedAppProfiles,
        configExists: true,
      ));

      // Construir el mapa actualizado
      final updatedProfiles = <String, ProfileType>{};
      for (final app in updatedAppProfiles) {
        if (app.assignedProfile != null) {
          updatedProfiles[app.appInfo.packageName] = app.assignedProfile!;
        }
      }

      // Guardar en disco
      await _repository.saveAppProfiles(updatedProfiles, currentState.defaultProfile);

      await _visibilityNotifier.show();

    } catch (e, stackTrace) {
      // Revertir en caso de error
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
      // Optimistic update
      state = AsyncValue.data(currentState.copyWith(
        defaultProfile: profile,
        configExists: true,
      ));

      final profileMap = <String, ProfileType>{};
      for (final app in currentState.appProfiles) {
        if (app.assignedProfile != null) {
          profileMap[app.appInfo.packageName] = app.assignedProfile!;
        }
      }

      await _repository.saveAppProfiles(profileMap, profile);

    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      await initialize();
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
