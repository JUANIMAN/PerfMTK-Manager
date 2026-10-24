import 'package:manager/core/errors/app_exception.dart';
import 'package:manager/core/logging/app_logger.dart';
import 'package:manager/core/platform/daemon_gateway.dart';
import 'package:manager/core/platform/perfmtk_paths.dart';
import 'package:manager/features/system/data/models/profile.dart';
import 'package:manager/features/system/data/models/system_state.dart';

/// Interface del repositorio del sistema
abstract class SystemRepository {
  Future<SystemState> getSystemState();
  Future<ProfileType> getCurrentProfile();
  Future<ThermalState> getCurrentThermal();
  Future<void> setProfile(ProfileType profile);
  Future<void> setThermal(ThermalState thermalState);
  Future<void> setChargeBypass(bool enabled);
  Future<void> setBatteryCare(bool enabled, int limitPct);
  Future<void> setChargeCurrentLimit(int ma);
}

/// Implementación del repositorio
class SystemRepositoryImpl implements SystemRepository {
  static const String _tag = 'SystemRepository';

  final DaemonGateway _gateway;

  const SystemRepositoryImpl({required DaemonGateway gateway})
    : _gateway = gateway;

  @override
  Future<SystemState> getSystemState() async {
    var thermal = ThermalState.enabled;
    try {
      thermal = await getCurrentThermal();
    } on SystemCommandException catch (e) {
      AppLogger.warn(_tag, 'thermal state unavailable, assuming enabled', e);
    }

    // 1. Direct LocalSocket IPC first (< 0.5ms, 0 processes)
    final ipcJson = await _gateway.ipcJson('STATUS_JSON');
    final fromIpc = ipcJson == null ? null : _tryParse(ipcJson, thermal);
    if (fromIpc != null) return fromIpc;

    // 2. Fallback to shell execution (older daemons may lack `-s --json`)
    final shellJson = await _gateway.shellJson(
      'perfmtk -s --json',
      timeout: const Duration(seconds: 6),
    );
    final fromShell = shellJson == null ? null : _tryParse(shellJson, thermal);
    if (fromShell != null) return fromShell;

    final profile = await getCurrentProfile();
    return SystemState(currentProfile: profile, thermalState: thermal);
  }

  SystemState? _tryParse(Map<String, dynamic> json, ThermalState thermal) {
    try {
      return SystemState.fromJson(json, thermalState: thermal);
    } on TypeError catch (e) {
      AppLogger.warn(_tag, 'unexpected status payload shape', e);
      return null;
    }
  }

  @override
  Future<ProfileType> getCurrentProfile() async {
    return ProfileType.fromString(
      (await _getProp('sys.perfmtk.current_profile', 'profile')).trim(),
    );
  }

  @override
  Future<ThermalState> getCurrentThermal() async {
    return ThermalState.fromString(
      (await _getProp('sys.perfmtk.thermal_state', 'thermal state')).trim(),
    );
  }

  Future<String> _getProp(String key, String label) async {
    try {
      return await _gateway.shell('getprop $key');
    } on RootShellException catch (e) {
      throw SystemCommandException('Failed to get $label: $e');
    } on Exception catch (e) {
      throw SystemCommandException('Unexpected error getting $label: $e');
    }
  }

  @override
  Future<void> setProfile(ProfileType profile) => _run(
    'setting profile',
    () async {
      await _gateway.command(
        'APPLY',
        arg: profile.value,
        shellFallback: 'perfmtk ${profile.value}',
        timeout: const Duration(seconds: 20),
      );

      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (await getCurrentProfile() != profile) {
        throw const SystemCommandException('Profile was not applied correctly');
      }
    },
  );

  @override
  Future<void> setThermal(ThermalState thermalState) => _run(
    'setting thermal state',
    () async {
      final arg = thermalState == ThermalState.enabled ? 'enable' : 'disable';
      await _gateway.command(
        'THERMAL_LIMIT',
        arg: arg,
        shellFallback:
            '${PerfMtkPaths.binary} -t $arg || '
            'perfmtk -t $arg || '
            '${PerfMtkPaths.moduleDir}/system/bin/thermal_limit $arg || '
            'thermal_limit $arg',
      );

      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (await getCurrentThermal() != thermalState) {
        throw const SystemCommandException(
          'Thermal state was not applied correctly',
        );
      }
    },
  );

  @override
  Future<void> setChargeBypass(bool enabled) => _run(
    'setting charge bypass',
    () {
      final arg = enabled ? 'on' : 'off';
      return _gateway.command(
        'CHARGE_BYPASS',
        arg: arg,
        shellFallback: 'perfmtk -c $arg',
        timeout: const Duration(seconds: 10),
      );
    },
  );

  @override
  Future<void> setBatteryCare(bool enabled, int limitPct) => _run(
    'setting battery care',
    () {
      final arg = enabled ? 'on $limitPct' : 'off';
      return _gateway.command(
        'BATTERY_CARE',
        arg: arg,
        shellFallback: 'perfmtk -b $arg',
        timeout: const Duration(seconds: 10),
      );
    },
  );

  @override
  Future<void> setChargeCurrentLimit(int ma) => _run(
    'setting charge current limit',
    () {
      final arg = ma.toString();
      return _gateway.command(
        'CHARGE_CURRENT',
        arg: arg,
        shellFallback: 'perfmtk -cc $arg',
        timeout: const Duration(seconds: 10),
      );
    },
  );

  /// Normalizes every failure into [SystemCommandException].
  Future<void> _run(String what, Future<void> Function() action) async {
    try {
      await action();
    } on SystemCommandException {
      rethrow;
    } on RootShellException catch (e) {
      throw SystemCommandException('Failed $what: $e');
    } on Exception catch (e) {
      throw SystemCommandException('Unexpected error $what: $e');
    }
  }
}
