import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/logging/app_logger.dart';
import 'package:manager/core/providers/daemon_providers.dart';
import 'package:manager/features/system/data/models/profile.dart';
import 'package:manager/features/system/data/models/system_state.dart';
import 'package:manager/features/system/data/system_repository.dart';
import 'package:manager/features/system/data/telemetry_stream_service.dart';
import 'package:manager/features/app_profiles/presentation/config_repository_provider.dart';

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

/// User-triggered operations that change daemon state.
enum SystemAction {
  profile,
  thermal,
  chargeBypass,
  batteryCare,
  chargeCurrentLimit,
}

/// Tracks in-flight [SystemAction]s (counted, so overlapping calls of the same
/// action keep it pending until the last one finishes).
class PendingActionsNotifier extends Notifier<Map<SystemAction, int>> {
  @override
  Map<SystemAction, int> build() => const {};

  void begin(SystemAction action) {
    state = {...state, action: (state[action] ?? 0) + 1};
  }

  void end(SystemAction action) {
    final remaining = (state[action] ?? 1) - 1;
    final next = {...state};
    if (remaining <= 0) {
      next.remove(action);
    } else {
      next[action] = remaining;
    }
    state = next;
  }
}

final pendingActionsProvider =
    NotifierProvider<PendingActionsNotifier, Map<SystemAction, int>>(
      PendingActionsNotifier.new,
    );

/// Whether [action] is currently in flight.
final isActionPendingProvider = Provider.family<bool, SystemAction>((
  ref,
  action,
) {
  return ref.watch(
    pendingActionsProvider.select((pending) => (pending[action] ?? 0) > 0),
  );
});

final isChangingProfileProvider = Provider<bool>(
  (ref) => ref.watch(isActionPendingProvider(SystemAction.profile)),
);
final isChangingThermalProvider = Provider<bool>(
  (ref) => ref.watch(isActionPendingProvider(SystemAction.thermal)),
);
final isChangingChargeBypassProvider = Provider<bool>(
  (ref) => ref.watch(isActionPendingProvider(SystemAction.chargeBypass)),
);
final isChangingBatteryCareProvider = Provider<bool>(
  (ref) => ref.watch(isActionPendingProvider(SystemAction.batteryCare)),
);
final isChangingChargeCurrentLimitProvider = Provider<bool>(
  (ref) => ref.watch(isActionPendingProvider(SystemAction.chargeCurrentLimit)),
);

/// How long an acknowledged change keeps masking stale daemon snapshots.
final systemSettleGraceProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 2),
);

/// Provider del estado del sistema (perfil activo + telemetría + estado térmico + bypass).
final systemStateProvider =
    AsyncNotifierProvider<SystemStateNotifier, SystemState>(
      SystemStateNotifier.new,
    );

typedef _StateEdit = SystemState Function(SystemState state);

class _Override {
  final _StateEdit apply;
  DateTime? settledUntil;
  Timer? expiry;
  _Override(this.apply);
}

/// Single source of truth for [SystemState].
///
/// The daemon stream (or a repository read) feeds [_base]; user actions layer
/// optimistic [_overrides] on top of it. Stream ticks therefore can never wipe
/// an in-flight change, and a failed action simply drops its override.
class SystemStateNotifier extends AsyncNotifier<SystemState> {
  static const String _tag = 'SystemState';

  SystemRepository get _repository => ref.read(systemRepositoryProvider);

  SystemState? _base;
  final Map<SystemAction, _Override> _overrides = {};
  StreamSubscription<SystemState>? _telemetrySub;

  @override
  Future<SystemState> build() async {
    final streamService = ref.watch(telemetryStreamServiceProvider);

    await _telemetrySub?.cancel();
    _telemetrySub = streamService.stream.listen((streamed) {
      _base = streamed;
      _publish();
    });

    ref.onDispose(() {
      _telemetrySub?.cancel();
      _telemetrySub = null;
      for (final o in _overrides.values) {
        o.expiry?.cancel();
      }
      _overrides.clear();
    });

    _base = streamService.latestState ?? await _repository.getSystemState();
    return _compose(_base!);
  }

  SystemState _compose(SystemState base) {
    final now = DateTime.now();
    _overrides.removeWhere((_, o) {
      final until = o.settledUntil;
      return until != null && !now.isBefore(until);
    });
    return _overrides.values.fold(base, (s, o) => o.apply(s));
  }

  void _publish() {
    final base = _base;
    if (base == null) return;
    state = AsyncData(_compose(base));
  }

  /// Applies [optimistic] immediately, runs [action], and on failure drops the
  /// change and rethrows so the caller can report it.
  Future<void> _perform(
    SystemAction action,
    _StateEdit optimistic,
    Future<void> Function() run,
  ) async {
    final pending = ref.read(pendingActionsProvider.notifier)..begin(action);
    final override = _Override(optimistic);
    _overrides[action]?.expiry?.cancel();
    _overrides[action] = override;
    _publish();

    try {
      await run();
      final grace = ref.read(systemSettleGraceProvider);
      override.settledUntil = DateTime.now().add(grace);
      override.expiry = Timer(grace, () {
        if (ref.mounted) _publish();
      });
    } on Object catch (error, stackTrace) {
      AppLogger.warn(_tag, '${action.name} failed', error, stackTrace);
      if (identical(_overrides[action], override)) _overrides.remove(action);
      _publish();
      rethrow;
    } finally {
      pending.end(action);
    }
  }

  /// Aplica un perfil al sistema con actualización optimista inmediata.
  Future<void> setProfile(ProfileType profile) => _perform(
    SystemAction.profile,
    (s) => s.copyWith(currentProfile: profile),
    () async {
      await _repository.setProfile(profile);
      await ref.read(configRepositoryProvider).updateDefaultProfile(profile);
    },
  );

  /// Aplica el estado térmico al sistema con actualización optimista inmediata.
  Future<void> setThermalState(ThermalState thermalState) => _perform(
    SystemAction.thermal,
    (s) => s.copyWith(thermalState: thermalState),
    () => _repository.setThermal(thermalState),
  );

  /// Activa o desactiva el Smart Fast Charge Bypass con actualización optimista inmediata.
  Future<void> setChargeBypass(bool enabled) => _perform(
    SystemAction.chargeBypass,
    (s) => s.copyWith(
      chargeBypass: enabled,
      chargeMode: enabled ? 'bypass' : 'normal',
    ),
    () => _repository.setChargeBypass(enabled),
  );

  /// Activa o desactiva el Battery Care con un límite porcentual (actualización optimista).
  Future<void> setBatteryCare(bool enabled, int limitPct) => _perform(
    SystemAction.batteryCare,
    (s) => s.copyWith(batteryCareEnabled: enabled, batteryCareLimitPct: limitPct),
    () => _repository.setBatteryCare(enabled, limitPct),
  );

  /// Regula el límite de corriente de carga en mA con actualización optimista inmediata (0 = Turbo).
  Future<void> setChargeCurrentLimit(int ma) => _perform(
    SystemAction.chargeCurrentLimit,
    (s) => s.copyWith(chargeCurrentLimitMa: ma),
    () => _repository.setChargeCurrentLimit(ma),
  );

  /// Recarga el estado del sistema (pull-to-refresh, vuelta a primer plano).
  ///
  /// Con datos ya cargados no se pasa por `AsyncLoading`, de modo que la UI no
  /// parpadea con un spinner; solo se muestra la carga si aún no hay datos.
  Future<void> refresh() async {
    if (!state.hasValue) state = const AsyncLoading();
    try {
      _base = await _repository.getSystemState();
      _publish();
    } on Object catch (error, stackTrace) {
      AppLogger.warn(_tag, 'refresh failed', error, stackTrace);
      if (!state.hasValue) state = AsyncError(error, stackTrace);
    }
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
