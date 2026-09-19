import 'dart:convert';
import 'package:manager/core/native_ipc_channel.dart';
import 'package:manager/core/root_shell_manager.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/system_state.dart';

/// Interface del repositorio del sistema
abstract class SystemRepository {
  Future<SystemState> getSystemState();
  Future<ProfileType> getCurrentProfile();
  Future<ThermalState> getCurrentThermal();
  Future<void> setProfile(ProfileType profile);
  Future<void> setThermal(ThermalState thermalState);
  Future<void> setChargeBypass(bool enabled);
  Future<bool> getChargeBypassStatus();
  Future<void> setBatteryCare(bool enabled, int limitPct);
  Future<void> setThermalGuardian(bool enabled, {int? targetTempC, int? maxSteps});
  Future<String> getThermalGuardianStatus();
  Future<bool> checkRootAccess();
}

/// Implementación del repositorio
class SystemRepositoryImpl implements SystemRepository {
  final ShellCommandExecutor _shellManager;
  final NativeIpcChannel _nativeIpc;

  SystemRepositoryImpl({
    ShellCommandExecutor? shellManager,
    NativeIpcChannel? nativeIpc,
  })  : _shellManager = shellManager ?? RootShellManager(),
        _nativeIpc = nativeIpc ?? NativeIpcChannel();

  @override
  Future<SystemState> getSystemState() async {
    ThermalState thermal = ThermalState.enabled;
    try {
      thermal = await getCurrentThermal();
    } catch (_) {}

    // 1. Direct LocalSocket IPC first (< 0.5ms, 0 processes)
    try {
      final jsonStr = await _nativeIpc.sendCommand('STATUS_JSON');
      if (jsonStr != null) {
        final trimmed = jsonStr.trim();
        final start = trimmed.indexOf('{');
        final end = trimmed.lastIndexOf('}');
        if (start != -1 && end != -1 && end > start) {
          final extracted = trimmed.substring(start, end + 1);
          final decoded = jsonDecode(extracted) as Map<String, dynamic>;
          return SystemState.fromJson(decoded, thermalState: thermal);
        }
      }
    } catch (_) {}

    // 2. Fallback to shell execution
    try {
      final jsonStr = await _shellManager.executeCommand(
        'perfmtk -s --json',
        timeout: const Duration(seconds: 6),
      );
      final trimmed = jsonStr.trim();
      final start = trimmed.indexOf('{');
      final end = trimmed.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final extracted = trimmed.substring(start, end + 1);
        final decoded = jsonDecode(extracted) as Map<String, dynamic>;
        return SystemState.fromJson(decoded, thermalState: thermal);
      }
    } catch (_) {
      // Fallback if daemon is older or -s --json is not ready
    }

    final profile = await getCurrentProfile();
    return SystemState(currentProfile: profile, thermalState: thermal);
  }

  @override
  Future<ProfileType> getCurrentProfile() async {
    try {
      final result = await _shellManager.executeCommand(
        'getprop sys.perfmtk.current_profile',
      );
      return ProfileType.fromString(result.trim());
    } on RootShellException catch (e) {
      throw SystemCommandException('Failed to get profile: $e');
    } catch (e) {
      throw SystemCommandException('Unexpected error getting profile: $e');
    }
  }

  @override
  Future<ThermalState> getCurrentThermal() async {
    try {
      final result = await _shellManager.executeCommand(
        'getprop sys.perfmtk.thermal_state',
      );
      return ThermalState.fromString(result.trim());
    } on RootShellException catch (e) {
      throw SystemCommandException('Failed to get thermal state: $e');
    } catch (e) {
      throw SystemCommandException('Unexpected error getting thermal state: $e');
    }
  }

  @override
  Future<void> setProfile(ProfileType profile) async {
    try {
      // Fast-path via direct LocalSocket
      final resp = await _nativeIpc.sendCommand('APPLY', profile.value);
      if (resp == null || !resp.startsWith('OK')) {
        await _shellManager.executeCommand(
          'perfmtk ${profile.value}',
          timeout: const Duration(seconds: 20),
        );
      }

      await Future.delayed(const Duration(milliseconds: 250));
      final current = await getCurrentProfile();

      if (current != profile) {
        throw SystemCommandException('Profile was not applied correctly');
      }
    } on SystemCommandException {
      rethrow;
    } catch (e) {
      throw SystemCommandException('Unexpected error setting profile: $e');
    }
  }

  @override
  Future<void> setThermal(ThermalState thermalState) async {
    try {
      final command =
          thermalState == ThermalState.enabled ? 'enable' : 'disable';
      final resp = await _nativeIpc.sendCommand('THERMAL_LIMIT', command);
      if (resp == null || !resp.startsWith('OK')) {
        await _shellManager.executeCommand(
          '/data/adb/modules/perfmtk/system/bin/perfmtk -t $command || '
          'perfmtk -t $command || '
          '/data/adb/modules/perfmtk/system/bin/thermal_limit $command || '
          'thermal_limit $command',
        );
      }

      await Future.delayed(const Duration(milliseconds: 300));
      final current = await getCurrentThermal();

      if (current != thermalState) {
        throw SystemCommandException('Thermal state was not applied correctly');
      }
    } on SystemCommandException {
      rethrow;
    } catch (e) {
      throw SystemCommandException('Unexpected error setting thermal state: $e');
    }
  }

  @override
  Future<void> setChargeBypass(bool enabled) async {
    try {
      final arg = enabled ? 'on' : 'off';
      final resp = await _nativeIpc.sendCommand('CHARGE_BYPASS', arg);
      if (resp == null || !resp.startsWith('OK')) {
        await _shellManager.executeCommand(
          'perfmtk -c $arg',
          timeout: const Duration(seconds: 10),
        );
      }
    } on RootShellException catch (e) {
      throw SystemCommandException('Failed to set charge bypass: $e');
    } catch (e) {
      throw SystemCommandException('Unexpected error setting charge bypass: $e');
    }
  }

  @override
  Future<bool> getChargeBypassStatus() async {
    try {
      final resp = await _nativeIpc.sendCommand('CHARGE_BYPASS', 'status');
      if (resp != null && resp.isNotEmpty) {
        return resp.toUpperCase().contains('CHARGE_BYPASS=ON');
      }
      final result = await _shellManager.executeCommand(
        'perfmtk -c status',
        timeout: const Duration(seconds: 5),
      );
      return result.toUpperCase().contains('CHARGE_BYPASS=ON');
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setBatteryCare(bool enabled, int limitPct) async {
    try {
      final arg = enabled ? 'on $limitPct' : 'off';
      final resp = await _nativeIpc.sendCommand('BATTERY_CARE', arg);
      if (resp == null || !resp.startsWith('OK')) {
        await _shellManager.executeCommand(
          'perfmtk -b $arg',
          timeout: const Duration(seconds: 10),
        );
      }
    } on RootShellException catch (e) {
      throw SystemCommandException('Failed to set battery care: $e');
    } catch (e) {
      throw SystemCommandException('Unexpected error setting battery care: $e');
    }
  }

  @override
  Future<void> setThermalGuardian(
    bool enabled, {
    int? targetTempC,
    int? maxSteps,
  }) async {
    try {
      final arg = enabled
          ? 'enable ${targetTempC ?? 75} ${maxSteps ?? 2}'
          : 'disable';
      final resp = await _nativeIpc.sendCommand('THERMAL_GUARDIAN', arg);
      if (resp == null || !resp.startsWith('OK')) {
        await _shellManager.executeCommand(
          'perfmtk --thermal-guardian $arg',
          timeout: const Duration(seconds: 10),
        );
      }
    } on RootShellException catch (e) {
      throw SystemCommandException('Failed to set Thermal Guardian: $e');
    } catch (e) {
      throw SystemCommandException('Unexpected error setting Thermal Guardian: $e');
    }
  }

  @override
  Future<String> getThermalGuardianStatus() async {
    try {
      final resp = await _nativeIpc.sendCommand('THERMAL_GUARDIAN', 'status');
      if (resp != null && resp.isNotEmpty) {
        return resp;
      }
      final result = await _shellManager.executeCommand(
        'perfmtk --thermal-guardian status',
        timeout: const Duration(seconds: 5),
      );
      return result;
    } catch (_) {
      return '';
    }
  }

  @override
  Future<bool> checkRootAccess() async {
    try {
      await _shellManager.initialize();
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Excepción personalizada para errores de comandos del sistema.
class SystemCommandException implements Exception {
  final String message;
  const SystemCommandException(this.message);

  @override
  String toString() => 'SystemCommandException: $message';
}
