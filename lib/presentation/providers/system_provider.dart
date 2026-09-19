import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/providers/shell_provider.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/data/repositories/system_repository.dart';
import 'package:manager/data/services/telemetry_stream_service.dart';
import 'package:manager/presentation/providers/config_repository_provider.dart';

/// Provider del repositorio del sistema
final systemRepositoryProvider = Provider<SystemRepository>((ref) {
  return SystemRepositoryImpl(
    shellManager: ref.watch(shellExecutorProvider),
  );
});

/// Provider del servicio de streaming persistente de telemetría (Zero-Fork).
final telemetryStreamServiceProvider = Provider<TelemetryStreamService>((ref) {
  final service = TelemetryStreamService(intervalMs: 2000);
  service.start();
  ref.onDispose(service.dispose);
  return service;
});

/// Notifier booleano puro de Riverpod 3 (reemplazo moderno para `StateProvider<bool>`)
class BooleanNotifier extends Notifier<bool> {
  final bool _initial;
  BooleanNotifier([this._initial = false]);

  @override
  bool build() => _initial;

  @override
  set state(bool value) => super.state = value;
}

/// Providers de estado de carga de acciones puntuales
final isChangingProfileProvider = NotifierProvider<BooleanNotifier, bool>(
  BooleanNotifier.new,
);
final isChangingThermalProvider = NotifierProvider<BooleanNotifier, bool>(
  BooleanNotifier.new,
);
final isChangingChargeBypassProvider = NotifierProvider<BooleanNotifier, bool>(
  BooleanNotifier.new,
);
final isChangingBatteryCareProvider = NotifierProvider<BooleanNotifier, bool>(
  BooleanNotifier.new,
);
final isChangingThermalGuardianProvider = NotifierProvider<BooleanNotifier, bool>(
  BooleanNotifier.new,
);

/// Verificación de acceso root
final rootAccessProvider = FutureProvider<bool>((ref) async {
  return ref.read(systemRepositoryProvider).checkRootAccess();
});

/// Provider del estado del sistema (perfil activo + telemetría + estado térmico + bypass).
final systemStateProvider =
    AsyncNotifierProvider<SystemStateNotifier, SystemState>(
      SystemStateNotifier.new,
    );

class SystemStateNotifier extends AsyncNotifier<SystemState> {
  SystemRepository get _repository => ref.read(systemRepositoryProvider);
  StreamSubscription<SystemState>? _telemetrySub;

  @override
  Future<SystemState> build() async {
    final streamService = ref.watch(telemetryStreamServiceProvider);

    _telemetrySub?.cancel();
    _telemetrySub = streamService.stream.listen((streamedState) {
      state = AsyncData(streamedState);
    });

    ref.onDispose(() {
      _telemetrySub?.cancel();
      _telemetrySub = null;
    });

    if (streamService.latestState != null) {
      return streamService.latestState!;
    }

    return _repository.getSystemState();
  }

  /// Aplica un perfil al sistema.
  Future<void> setProfile(ProfileType profile) async {
    ref.read(isChangingProfileProvider.notifier).state = true;

    try {
      await _repository.setProfile(profile);

      // Atomic read-modify-write: this does not depend on the installed-apps
      // provider having completed its asynchronous initialization.
      await ref.read(configRepositoryProvider).updateDefaultProfile(profile);

      // Recargar estado del sistema para reflejar el valor real
      state = AsyncData(await build());
    } catch (error, stackTrace) {
      // Recover the displayed state, but let the UI report the failed action.
      state = await AsyncValue.guard(build);
      Error.throwWithStackTrace(error, stackTrace);
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
    } catch (error, stackTrace) {
      state = await AsyncValue.guard(build);
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      ref.read(isChangingThermalProvider.notifier).state = false;
    }
  }

  /// Activa o desactiva el Smart Fast Charge Bypass.
  Future<void> setChargeBypass(bool enabled) async {
    ref.read(isChangingChargeBypassProvider.notifier).state = true;

    try {
      await _repository.setChargeBypass(enabled);
      state = AsyncData(await build());
    } catch (error, stackTrace) {
      state = await AsyncValue.guard(build);
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      ref.read(isChangingChargeBypassProvider.notifier).state = false;
    }
  }

  /// Activa o desactiva el Battery Care con un límite porcentual.
  Future<void> setBatteryCare(bool enabled, int limitPct) async {
    ref.read(isChangingBatteryCareProvider.notifier).state = true;

    try {
      await _repository.setBatteryCare(enabled, limitPct);
      state = AsyncData(await build());
    } catch (error, stackTrace) {
      state = await AsyncValue.guard(build);
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      ref.read(isChangingBatteryCareProvider.notifier).state = false;
    }
  }

  /// Configura el Thermal Guardian proactivo.
  Future<void> setThermalGuardian(
    bool enabled, {
    int? targetTempC,
    int? maxSteps,
  }) async {
    ref.read(isChangingThermalGuardianProvider.notifier).state = true;

    try {
      await _repository.setThermalGuardian(
        enabled,
        targetTempC: targetTempC,
        maxSteps: maxSteps,
      );
      state = AsyncData(await build());
    } catch (error, stackTrace) {
      state = await AsyncValue.guard(build);
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      ref.read(isChangingThermalGuardianProvider.notifier).state = false;
    }
  }

  /// Recarga silenciosa sin poner la UI en estado de carga (ideal para streaming de telemetría).
  Future<void> pollLiveMetrics() async {
    try {
      final updated = await _repository.getSystemState();
      state = AsyncData(updated);
    } catch (_) {}
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

/// Estado del bypass de carga actual (null mientras carga o en error)
final currentChargeBypassProvider = Provider<bool?>((ref) {
  return ref.watch(systemStateProvider).value?.chargeBypass;
});

/// Estado de Battery Care actual (null mientras carga o en error)
final currentBatteryCareProvider = Provider<bool?>((ref) {
  return ref.watch(systemStateProvider).value?.batteryCareEnabled;
});

/// Estado de Thermal Guardian actual (null mientras carga o en error)
final currentThermalGuardianProvider = Provider<bool?>((ref) {
  return ref.watch(systemStateProvider).value?.thermalGuardianEnabled;
});
