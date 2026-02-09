import 'dart:io';
import 'package:manager/core/root_shell_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:manager/data/models/profile.dart';

/// Interface del repositorio de la configuración
abstract class ConfigRepository {
  Future<bool> configExists();
  Future<Map<String, ProfileType>> loadAppProfiles();
  Future<ProfileType> getDefaultProfile();
  Future<void> saveAppProfiles(Map<String, ProfileType> profiles, ProfileType defaultProfile);
  Future<void> deleteConfig();
}

/// Implementación del repositorio
class ConfigRepositoryImpl implements ConfigRepository {
  final String _configFilePath = '/data/local/app_profiles.conf';
  final _shellManager = RootShellManager();

  @override
  Future<bool> configExists() async {
    try {
      final result = await _shellManager.executeCommand(
          'test -f $_configFilePath && echo "exists" || echo "not exists"'
      );
      return result.trim() == 'exists';
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, ProfileType>> loadAppProfiles() async {
    try {
      final content = await _shellManager.executeCommand('cat $_configFilePath');

      final lines = content.split('\n');
      final profiles = <String, ProfileType>{};

      for (final line in lines) {
        if (line.trim().isEmpty || line.startsWith('#') || line.startsWith('DEFAULT_PROFILE')) {
          continue;
        }

        final parts = line.split('=');
        if (parts.length == 2) {
          final packageName = parts[0].trim();
          final profileStr = parts[1].trim();
          profiles[packageName] = ProfileType.fromString(profileStr);
        }
      }

      return profiles;
    } catch (e) {
      if (e is ConfigReadException) rethrow;
      throw ConfigReadException('Unexpected error reading config: $e');
    }
  }

  @override
  Future<ProfileType> getDefaultProfile() async {
    try {
      final content = await _shellManager.executeCommand('cat $_configFilePath');

      final lines = content.split('\n');

      for (final line in lines) {
        if (line.startsWith('DEFAULT_PROFILE')) {
          final parts = line.split('=');
          if (parts.length == 2) {
            return ProfileType.fromString(parts[1].trim());
          }
        }
      }

      return ProfileType.balanced;
    } catch (e) {
      return ProfileType.balanced;
    }
  }

  @override
  Future<void> saveAppProfiles(
      Map<String, ProfileType> profiles,
      ProfileType defaultProfile
      ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/app_profiles.conf');

      final buffer = StringBuffer()
        ..writeln('# Configuration file for PerfMTK Daemon')
        ..writeln('# Format: package_name=energy_profile')
        ..writeln()
        ..writeln('# Default global profile when no application from the list is in the foreground')
        ..writeln('DEFAULT_PROFILE=${defaultProfile.value}')
        ..writeln();

      profiles.forEach((packageName, profile) {
        buffer.writeln('$packageName=${profile.value}');
      });

      await tempFile.writeAsString(buffer.toString());

      await _shellManager.executeCommand(
        'cp ${tempFile.path} $_configFilePath && chmod 644 $_configFilePath && sync'
      );

      await tempFile.delete();
    } catch (e) {
      if (e is ConfigWriteException) rethrow;
      throw ConfigWriteException('Unexpected error saving config: $e');
    }
  }

  @override
  Future<void> deleteConfig() async {
    try {
      await _shellManager.executeCommand('rm -f $_configFilePath && sync');
    } catch (e) {
      if (e is ConfigWriteException) rethrow;
      throw ConfigWriteException('Unexpected error deleting config: $e');
    }
  }
}

// Excepciones personalizadas
class ConfigReadException implements Exception {
  final String message;
  ConfigReadException(this.message);

  @override
  String toString() => 'ConfigReadException: $message';
}

class ConfigWriteException implements Exception {
  final String message;
  ConfigWriteException(this.message);

  @override
  String toString() => 'ConfigWriteException: $message';
}
