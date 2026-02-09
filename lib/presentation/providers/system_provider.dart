import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/data/repositories/system_repository.dart';
import 'package:manager/presentation/providers/app_profile_provider.dart';

// Provider del repositorio
final systemRepositoryProvider = Provider<SystemRepository>((ref) {
  return SystemRepositoryImpl();
});

// Provider del estado del sistema
final systemStateProvider = StateNotifierProvider<SystemStateNotifier, AsyncValue<SystemState>>((ref) {
  return SystemStateNotifier(
    ref.read(systemRepositoryProvider),
    ref,
  );
});

// Provider para verificar acceso root
final rootAccessProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(systemRepositoryProvider);
  return repository.checkRootAccess();
});

final isChangingProfileProvider = StateProvider<bool>((ref) => false);
final isChangingThermalProvider = StateProvider<bool>((ref) => false);

class SystemStateNotifier extends StateNotifier<AsyncValue<SystemState>> {
  final SystemRepository _repository;
  final Ref _ref;

  SystemStateNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    initialize();
  }

  /// Inicializa el estado del sistema
  Future<void> initialize() async {
    try {
      state = const AsyncValue.loading();

      final profileResult = await _repository.getCurrentProfile();
      final thermalResult = await _repository.getCurrentThermal();

      final systemState = SystemState(
        currentProfile: profileResult,
        thermalState: thermalResult,
      );

      state = AsyncValue.data(systemState);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Establece un nuevo perfil
  /// Si existe configuración de app profiles, actualiza el perfil por defecto también
  Future<void> setProfile(ProfileType profile) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      _ref.read(isChangingProfileProvider.notifier).state = true;

      // Aplicar el perfil
      await _repository.setProfile(profile);

      // Verificar si existe configuración de app profiles
      final appProfileState = _ref.read(appProfileProvider).value;
      final hasAppProfiles = appProfileState?.configExists ?? false;

      // Si hay app profiles, actualizar el perfil por defecto
      if (hasAppProfiles) {
        await _ref.read(appProfileProvider.notifier).setDefaultProfile(profile);
      }

      // Recargar estado del sistema
      await initialize();

    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      await initialize();
    } finally {
      _ref.read(isChangingProfileProvider.notifier).state = false;
    }
  }

  /// Establece el estado térmico
  Future<void> setThermalState(ThermalState thermalState) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      _ref.read(isChangingThermalProvider.notifier).state = true;

      await _repository.setThermal(thermalState);

      // Recargar estado
      await initialize();

    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      await initialize();
    } finally {
      _ref.read(isChangingThermalProvider.notifier).state = false;
    }
  }

  /// Recarga el estado del sistema
  Future<void> refresh() async {
    await initialize();
  }
}

// Provider derivado para obtener solo el perfil actual
final currentProfileProvider = Provider<ProfileType?>((ref) {
  return ref.watch(systemStateProvider).value?.currentProfile;
});

// Provider derivado para obtener solo el estado térmico
final currentThermalProvider = Provider<ThermalState?>((ref) {
  return ref.watch(systemStateProvider).value?.thermalState;
});