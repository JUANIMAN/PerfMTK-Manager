import 'package:manager/core/root_shell_manager.dart';
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
  final _shellManager = RootShellManager();

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
      await _shellManager.executeCommand(
        'perfmtk ${profile.value}',
        timeout: const Duration(seconds: 20),
      );

      await Future.delayed(const Duration(milliseconds: 500));
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
      await _shellManager.executeCommand('thermal_limit $command');

      await Future.delayed(const Duration(milliseconds: 500));
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