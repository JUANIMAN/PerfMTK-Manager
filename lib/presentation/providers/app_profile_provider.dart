import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:manager/data/models/app_profile.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/repositories/config_repository.dart';
import 'package:manager/presentation/providers/app_profile_visibility_provider.dart';

// Provider del repositorio
final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepositoryImpl();
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
      // Notificar al provider de visibilidad
      ref.read(appProfileVisibilityProvider.notifier).show();
    }

    final installedApps = await InstalledApps.getInstalledApps(
      withIcon: true,
      excludeSystemApps: !includeSystemApps,
    );

    final appProfiles = installedApps.map((app) {
      return AppProfile(
        appInfo: app,
        assignedProfile: config.appProfiles[app.packageName],
      );
    }).toList()
      ..sort((a, b) => a.appInfo.name.compareTo(b.appInfo.name));

    return AppProfileState(
      appProfiles: appProfiles,
      defaultProfile: config.defaultProfile,
      configExists: configExists,
      includeSystemApps: includeSystemApps,
    );
  }

  /// Actualiza el perfil de una app específica
  Future<void> setAppProfile(String packageName, ProfileType? profile) async {
    final current = state.requireValue;

    // Leer el mapa completo desde disco
    final diskConfig = await _repository.loadConfig();
    final updatedProfiles = Map<String, ProfileType>.from(diskConfig.appProfiles)
      ..remove(packageName);
    if (profile != null) updatedProfiles[packageName] = profile;

    await _repository.saveAppProfiles(updatedProfiles, current.defaultProfile);
    await ref.read(appProfileVisibilityProvider.notifier).show();

    // Recargar desde disco para reflejar el estado real
    state = AsyncData(await _load(includeSystemApps: current.includeSystemApps));
  }

  /// Actualiza el perfil por defecto
  Future<void> setDefaultProfile(ProfileType profile) async {
    final current = state.requireValue;

    final diskConfig = await _repository.loadConfig();

    await _repository.saveAppProfiles(diskConfig.appProfiles, profile);
    state = AsyncData(await _load(includeSystemApps: current.includeSystemApps));
  }

  /// Cambia si se muestran apps del sistema y recarga la lista
  Future<void> toggleSystemApps(bool include) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
          () => _load(includeSystemApps: include),
    );
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

enum AppFilterType {
  all,
  configured,
  notConfigured,
}