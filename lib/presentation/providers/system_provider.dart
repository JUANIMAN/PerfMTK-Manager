import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/providers/daemon_providers.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/data/repositories/system_repository.dart';
import 'package:manager/data/services/telemetry_stream_service.dart';
import 'package:manager/presentation/providers/config_repository_provider.dart';

/// Provider del repositorio del sistema
final systemRepositoryProvider = Provider<SystemRepository>((ref) {
  return SystemRepositoryImpl(gateway: ref.watch(daemonGatewayProvider));
});

/// Provider del servicio de streaming persistente de telemetría (Zero-Fork).
final telemetryStreamServiceProvider = Provider<TelemetryStreamService>((ref) {
  final service = TelemetryStreamService(
    intervalMs: 2000,
    ipcChannel: ref.watch(nativeIpcProvider),
  );
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
final isChangingChargeCurrentLimitProvider =
    NotifierProvider<BooleanNotifier, bool>(
  BooleanNotifier.new,
);

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

  /// Aplica un perfil al sistema con actualización optimista inmediata.
  Future<void> setProfile(ProfileType profile) async {
    ref.read(isChangingProfileProvider.notifier).state = true;
    final current = state.value;
    if (current != null) {
      final optimistic = current.copyWith(currentProfile: profile);
      state = AsyncData(optimistic);
      ref.read(telemetryStreamServiceProvider).updateLatest(optimistic);
    }

    try {
      await _repository.setProfile(profile);
      await ref.read(configRepositoryProvider).updateDefaultProfile(profile);
    } catch (error, stackTrace) {
      if (current != null) {
        state = AsyncData(current);
        ref.read(telemetryStreamServiceProvider).updateLatest(current);
      }
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      ref.read(isChangingProfileProvider.notifier).state = false;
    }
  }

  /// Aplica el estado térmico al sistema con actualización optimista inmediata.
  Future<void> setThermalState(ThermalState thermalState) async {
    ref.read(isChangingThermalProvider.notifier).state = true;
    final current = state.value;
    if (current != null) {
      final optimistic = current.copyWith(thermalState: thermalState);
      state = AsyncData(optimistic);
      ref.read(telemetryStreamServiceProvider).updateLatest(optimistic);
    }

    try {
      await _repository.setThermal(thermalState);
    } catch (error, stackTrace) {
      if (current != null) {
        state = AsyncData(current);
        ref.read(telemetryStreamServiceProvider).updateLatest(current);
      }
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      ref.read(isChangingThermalProvider.notifier).state = false;
    }
  }

  /// Activa o desactiva el Smart Fast Charge Bypass con actualización optimista inmediata.
  Future<void> setChargeBypass(bool enabled) async {
    ref.read(isChangingChargeBypassProvider.notifier).state = true;
    final current = state.value;
    if (current != null) {
      final optimistic = current.copyWith(
        chargeBypass: enabled,
        chargeMode: enabled ? 'bypass' : 'normal',
      );
      state = AsyncData(optimistic);
      ref.read(telemetryStreamServiceProvider).updateLatest(optimistic);
    }

    try {
      await _repository.setChargeBypass(enabled);
    } catch (error, stackTrace) {
      if (current != null) {
        state = AsyncData(current);
        ref.read(telemetryStreamServiceProvider).updateLatest(current);
      }
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      ref.read(isChangingChargeBypassProvider.notifier).state = false;
    }
  }

  /// Activa o desactiva el Battery Care con un límite porcentual (actualización optimista).
  Future<void> setBatteryCare(bool enabled, int limitPct) async {
    ref.read(isChangingBatteryCareProvider.notifier).state = true;
    final current = state.value;
    if (current != null) {
      final optimistic = current.copyWith(
        batteryCareEnabled: enabled,
        batteryCareLimitPct: limitPct,
      );
      state = AsyncData(optimistic);
      ref.read(telemetryStreamServiceProvider).updateLatest(optimistic);
    }

    try {
      await _repository.setBatteryCare(enabled, limitPct);
    } catch (error, stackTrace) {
      if (current != null) {
        state = AsyncData(current);
        ref.read(telemetryStreamServiceProvider).updateLatest(current);
      }
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      ref.read(isChangingBatteryCareProvider.notifier).state = false;
    }
  }

  /// Regula el límite de corriente de carga en mA con actualización optimista inmediata (0 = Turbo).
  Future<void> setChargeCurrentLimit(int ma) async {
    ref.read(isChangingChargeCurrentLimitProvider.notifier).state = true;
    final current = state.value;
    if (current != null) {
      final optimistic = current.copyWith(chargeCurrentLimitMa: ma);
      state = AsyncData(optimistic);
      ref.read(telemetryStreamServiceProvider).updateLatest(optimistic);
    }

    try {
      await _repository.setChargeCurrentLimit(ma);
    } catch (error, stackTrace) {
      if (current != null) {
        state = AsyncData(current);
        ref.read(telemetryStreamServiceProvider).updateLatest(current);
      }
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      ref.read(isChangingChargeCurrentLimitProvider.notifier).state = false;
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

/// Límite de corriente de carga configurado (null mientras carga o en error)
final currentChargeCurrentLimitProvider = Provider<int?>((ref) {
  return ref.watch(systemStateProvider).value?.chargeCurrentLimitMa;
});
