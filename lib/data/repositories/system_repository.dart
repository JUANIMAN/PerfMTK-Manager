import 'dart:io';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/system_state.dart';

/// Interface del repositorio del sistema
abstract class SystemRepository {
  Future<ProfileType> getCurrentProfile();
  Future<ThermalState> getCurrentThermal();
  Future<void> setProfile(ProfileType profile);
  Future<void> setThermal(ThermalState thermalState);
  Future<bool> checkRootAccess();
}

/// Implementación del repositorio
class SystemRepositoryImpl implements SystemRepository {
  @override
  Future<ProfileType> getCurrentProfile() async {
    try {
      final result = await Process.run('getprop', ['sys.perfmtk.current_profile']);

      if (result.exitCode != 0) {
        throw SystemCommandException('Failed to get profile: ${result.stderr}');
      }

      final profileStr = result.stdout.toString().trim();
      return ProfileType.fromString(profileStr);
    } catch (e) {
      if (e is SystemCommandException) rethrow;
      throw SystemCommandException('Unexpected error getting profile: $e');
    }
  }

  @override
  Future<ThermalState> getCurrentThermal() async {
    try {
      final result = await Process.run('getprop', ['sys.perfmtk.thermal_state']);

      if (result.exitCode != 0) {
        throw SystemCommandException('Failed to get thermal state: ${result.stderr}');
      }

      final thermalStr = result.stdout.toString().trim();
      return ThermalState.fromString(thermalStr);
    } catch (e) {
      if (e is SystemCommandException) rethrow;
      throw SystemCommandException('Unexpected error getting thermal state: $e');
    }
  }

  @override
  Future<void> setProfile(ProfileType profile) async {
    try {
      final result = await Process.run('su', [
        '-c',
        'perfmtk',
        profile.value,
      ]);

      if (result.exitCode != 0) {
        throw SystemCommandException('Failed to set profile: ${result.stderr}');
      }

      // Verificar que el perfil se aplicó correctamente
      await Future.delayed(const Duration(milliseconds: 500));
      final currentProfile = await getCurrentProfile();

      if (currentProfile != profile) {
        throw SystemCommandException('Profile was not applied correctly');
      }
    } catch (e) {
      if (e is SystemCommandException) rethrow;
      throw SystemCommandException('Unexpected error setting profile: $e');
    }
  }

  @override
  Future<void> setThermal(ThermalState thermalState) async {
    try {
      // Los comandos usan 'enable'/'disable', no 'enabled'/'disabled'
      final command = thermalState == ThermalState.enabled ? 'enable' : 'disable';

      final result = await Process.run('su', [
        '-c',
        'thermal_limit',
        command,
      ]);

      if (result.exitCode != 0) {
        throw SystemCommandException('Failed to set thermal state: ${result.stderr}');
      }

      // Verificar que se aplicó correctamente
      await Future.delayed(const Duration(milliseconds: 500));
      final currentThermal = await getCurrentThermal();

      if (currentThermal != thermalState) {
        throw SystemCommandException('Thermal state was not applied correctly');
      }
    } catch (e) {
      if (e is SystemCommandException) rethrow;
      throw SystemCommandException('Unexpected error setting thermal state: $e');
    }
  }

  @override
  Future<bool> checkRootAccess() async {
    try {
      final result = await Process.run('su', ['-c', 'echo "test"']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
}

// Excepción personalizada
class SystemCommandException implements Exception {
  final String message;
  SystemCommandException(this.message);

  @override
  String toString() => 'SystemCommandException: $message';
}