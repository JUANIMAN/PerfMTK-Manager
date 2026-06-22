import 'dart:io';
import 'package:manager/core/root_shell_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:manager/data/models/profile.dart';

/// Interface del repositorio de configuración
abstract class ConfigRepository {
  Future<bool> configExists();
  Future<ConfigData> loadConfig();
  Future<void> saveConfig(
      Map<String, ProfileType> profiles,
      ProfileType defaultProfile,
      ProfileType screenOffProfile,
      int appDebounceMs,
      );
  Future<void> deleteConfig();
}

class ConfigData {
  final Map<String, ProfileType> appProfiles;
  final ProfileType defaultProfile;
  final ProfileType screenOffProfile;
  final int appDebounceMs;
  final bool existsOnDisk;

  const ConfigData({
    required this.appProfiles,
    required this.defaultProfile,
    required this.screenOffProfile,
    required this.appDebounceMs,
    this.existsOnDisk = false,
  });

  factory ConfigData.empty() {
    return const ConfigData(
      appProfiles: {},
      defaultProfile: ProfileType.balanced,
      screenOffProfile: ProfileType.powersave,
      appDebounceMs: 3000,
      existsOnDisk: false,
    );
  }
}

class ConfigRepositoryImpl implements ConfigRepository {
  static const String _configFilePath = '/data/local/app_profiles.conf';
  final _shellManager = RootShellManager();

  @override
  Future<bool> configExists() async {
    try {
      final result = await _shellManager.executeCommand(
        'test -f $_configFilePath && echo "exists" || echo "not_exists"',
      );
      return result.trim() == 'exists';
    } catch (_) {
      return false;
    }
  }

  /// Lee y parsea el archivo de configuración
  @override
  Future<ConfigData> loadConfig() async {
    try {
      final exists = await configExists();
      if (!exists) return ConfigData.empty();

      final content =
      await _shellManager.executeCommand('cat $_configFilePath');
      return _parseConfig(content);
    } on RootShellException catch (e) {
      throw ConfigReadException('Shell error reading config: $e');
    }
  }

  ConfigData _parseConfig(String content) {
    final appProfiles = <String, ProfileType>{};
    ProfileType defaultProfile = ProfileType.balanced;
    ProfileType screenOffProfile = ProfileType.powersave;
    int appDebounceMs = 3000;

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      // Use indexOf so that values containing '=' are handled correctly
      final eqIndex = line.indexOf('=');
      if (eqIndex < 1) continue;

      final key = line.substring(0, eqIndex).trim();
      final value = line.substring(eqIndex + 1).trim();

      if (key == 'DEFAULT_PROFILE') {
        defaultProfile = ProfileType.fromString(value);
      } else if (key == 'SCREEN_OFF_PROFILE') {
        screenOffProfile = ProfileType.fromString(value);
      } else if (key == 'APP_DEBOUNCE_MS') {
        final parsed = int.tryParse(value);
        if (parsed != null) appDebounceMs = parsed.clamp(500, 10000);
      } else {
        appProfiles[key] = ProfileType.fromString(value);
      }
    }

    return ConfigData(
      appProfiles: appProfiles,
      defaultProfile: defaultProfile,
      screenOffProfile: screenOffProfile,
      appDebounceMs: appDebounceMs,
      existsOnDisk: true,
    );
  }

  @override
  Future<void> saveConfig(
      Map<String, ProfileType> profiles,
      ProfileType defaultProfile,
      ProfileType screenOffProfile,
      int appDebounceMs,
      ) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/app_profiles.conf');

    try {
      final buffer = StringBuffer()
        ..writeln('# Configuration file for PerfMTK Daemon')
        ..writeln('# Format: package_name=energy_profile')
        ..writeln()
        ..writeln('# Default global profile when no application from the list is in the foreground')
        ..writeln('DEFAULT_PROFILE=${defaultProfile.value}')
        ..writeln('SCREEN_OFF_PROFILE=${screenOffProfile.value}')
        ..writeln('APP_DEBOUNCE_MS=$appDebounceMs')
        ..writeln();

      profiles.forEach((packageName, profile) {
        buffer.writeln('$packageName=${profile.value}');
      });

      await tempFile.writeAsString(buffer.toString(), flush: true);

      await _shellManager.executeCommand(
        'cp ${tempFile.path} $_configFilePath && chmod 644 $_configFilePath && sync',
      );
    } on FileSystemException catch (e) {
      throw ConfigWriteException('Error writing temp file: ${e.message}');
    } on RootShellException catch (e) {
      throw ConfigWriteException(
          'Error copying config to destination: $e');
    } finally {
      if (await tempFile.exists()) await tempFile.delete();
    }
  }

  @override
  Future<void> deleteConfig() async {
    try {
      await _shellManager.executeCommand(
          'rm -f $_configFilePath && sync');
    } on RootShellException catch (e) {
      throw ConfigWriteException('Error deleting config: $e');
    }
  }
}

class ConfigReadException implements Exception {
  final String message;
  const ConfigReadException(this.message);

  @override
  String toString() => 'ConfigReadException: $message';
}

class ConfigWriteException implements Exception {
  final String message;
  const ConfigWriteException(this.message);

  @override
  String toString() => 'ConfigWriteException: $message';
}