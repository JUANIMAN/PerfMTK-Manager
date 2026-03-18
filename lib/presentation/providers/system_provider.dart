import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/data/repositories/system_repository.dart';
import 'package:manager/presentation/providers/app_profile_provider.dart';

/// Provider del repositorio
final systemRepositoryProvider = Provider<SystemRepository>((ref) {
  return SystemRepositoryImpl();
});

/// Providers de estado de carga de acciones puntuales
final isChangingProfileProvider = StateProvider<bool>((ref) => false);
final isChangingThermalProvider = StateProvider<bool>((ref) => false);

/// Verificación de acceso root
final rootAccessProvider = FutureProvider<bool>((ref) async {
  return ref.read(systemRepositoryProvider).checkRootAccess();
});

/// Provider del estado del sistema (perfil activo + estado térmico).
final systemStateProvider =
AsyncNotifierProvider<SystemStateNotifier, SystemState>(
  SystemStateNotifier.new,
);

class SystemStateNotifier extends AsyncNotifier<SystemState> {
  SystemRepository get _repository => ref.read(systemRepositoryProvider);

  @override
  Future<SystemState> build() async {
    final profile = await _repository.getCurrentProfile();
    final thermal = await _repository.getCurrentThermal();
    return SystemState(currentProfile: profile, thermalState: thermal);
  }

  /// Aplica un perfil al sistema.
  Future<void> setProfile(ProfileType profile) async {
    ref.read(isChangingProfileProvider.notifier).state = true;

    try {
      await _repository.setProfile(profile);

      // Coordinación opcional con appProfileProvider:
      final appProfileNotifier = ref.read(appProfileProvider.notifier);
      if (appProfileNotifier.hasConfig) {
        await appProfileNotifier.setDefaultProfile(profile);
      }

      // Recargar estado del sistema para reflejar el valor real de getprop
      state = AsyncData(await build());
    } catch (e, st) {
      state = AsyncError(e, st);
      // Intentar recuperar el estado actual aunque el cambio haya fallado
      state = await AsyncValue.guard(build);
    } finally {
      ref.read(isChangingProfileProvider.notifier).state = false;
    }
  }

  /// Aplica el estado térmico al sistema.
  Future<void> setThermalState(ThermalState thermalState) async {
    ref.read(isChangingThermalProvider.notifier).state = true;

    try {
      await _repository.setThermal(thermalState);
      state = AsyncData(await build());
    } catch (e, st) {
      state = AsyncError(e, st);
      state = await AsyncValue.guard(build);
    } finally {
      ref.read(isChangingThermalProvider.notifier).state = false;
    }
  }

  /// Recarga el estado del sistema (pull-to-refresh, etc.).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

/// Perfil activo actual (null mientras carga o en error)
final currentProfileProvider = Provider<ProfileType?>((ref) {
  return ref.watch(systemStateProvider).value?.currentProfile;
});

/// Estado térmico actual (null mientras carga o en error)
final currentThermalProvider = Provider<ThermalState?>((ref) {
  return ref.watch(systemStateProvider).value?.thermalState;
});