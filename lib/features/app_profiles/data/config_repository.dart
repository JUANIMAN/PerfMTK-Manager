import 'dart:io';
import 'package:manager/core/errors/app_exception.dart';
import 'package:manager/core/logging/app_logger.dart';
import 'package:manager/core/platform/daemon_gateway.dart';
import 'package:manager/core/platform/perfmtk_paths.dart';
import 'package:path_provider/path_provider.dart';
import 'package:manager/features/app_profiles/data/app_profile.dart';
import 'package:manager/features/system/data/models/profile.dart';

class AppProfileEntryData {
  final ProfileType profile;
  final AppDirectives directives;

  const AppProfileEntryData({
    required this.profile,
    this.directives = const AppDirectives(),
  });
}

/// Interface del repositorio de configuración
abstract class ConfigRepository {
  Future<bool> configExists();
  Future<ConfigData> loadConfig();
  Future<void> saveConfig(
    Map<String, AppProfileEntryData> entries,
    ProfileType defaultProfile,
    ProfileType screenOffProfile,
    int appDebounceMs,
  );
  Future<bool> updateDefaultProfile(ProfileType profile);
  Future<void> deleteConfig();
}

class ConfigData {
  final Map<String, AppProfileEntryData> entries;
  final ProfileType defaultProfile;
  final ProfileType screenOffProfile;
  final int appDebounceMs;
  final bool existsOnDisk;

  const ConfigData({
    required this.entries,
    required this.defaultProfile,
    required this.screenOffProfile,
    required this.appDebounceMs,
    this.existsOnDisk = false,
  });

  /// Map of pkg -> ProfileType for simple profile lookups
  Map<String, ProfileType> get appProfiles =>
      entries.map((k, v) => MapEntry(k, v.profile));

  factory ConfigData.empty() {
    return const ConfigData(
      entries: {},
      defaultProfile: ProfileType.balanced,
      screenOffProfile: ProfileType.powersave,
      appDebounceMs: 3000,
      existsOnDisk: false,
    );
  }
}

class ConfigRepositoryImpl implements ConfigRepository {
  static const String _tag = 'ConfigRepository';
  static const String _primaryConfigPath = PerfMtkPaths.appProfilesConf;
  static const String _fallbackConfigPath = PerfMtkPaths.appProfilesFallbackConf;

  final DaemonGateway _gateway;
  final Future<Directory> Function() _getTemporaryDirectory;
  Future<void> _writeQueue = Future.value();
  ProfileType? _latestDefaultProfile;

  ConfigRepositoryImpl({
    required DaemonGateway gateway,
    Future<Directory> Function()? getTempDirectory,
  }) : _gateway = gateway,
       _getTemporaryDirectory = getTempDirectory ?? getTemporaryDirectory;

  @override
  Future<bool> configExists() async {
    try {
      final result = await _gateway.shell(
        'test -f $_primaryConfigPath && echo "exists" || (test -f $_fallbackConfigPath && echo "exists" || echo "not_exists")',
      );
      return result.trim() == 'exists';
    } on RootShellException catch (e) {
      throw ConfigReadException('Shell error checking config: $e');
    }
  }

  /// Lee y parsea el archivo de configuración
  @override
  Future<ConfigData> loadConfig() async {
    try {
      final exists = await configExists();
      if (!exists) return ConfigData.empty();

      final content = await _gateway.shell(
        'cat $_primaryConfigPath 2>/dev/null || cat $_fallbackConfigPath',
      );
      return _parseConfig(content);
    } on RootShellException catch (e) {
      throw ConfigReadException('Shell error reading config: $e');
    }
  }

  ConfigData _parseConfig(String content) {
    final entries = <String, AppProfileEntryData>{};
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
        final parts = value.split(';');
        final profileStr = parts.first.trim();
        final profile = ProfileType.fromString(profileStr);
        final directives =
            parts.length > 1
                ? AppDirectives.fromParts(parts.sublist(1))
                : const AppDirectives();
        entries[key] = AppProfileEntryData(
          profile: profile,
          directives: directives,
        );
      }
    }

    return ConfigData(
      entries: entries,
      defaultProfile: defaultProfile,
      screenOffProfile: screenOffProfile,
      appDebounceMs: appDebounceMs,
      existsOnDisk: true,
    );
  }

  @override
  Future<void> saveConfig(
    Map<String, AppProfileEntryData> entries,
    ProfileType defaultProfile,
    ProfileType screenOffProfile,
    int appDebounceMs,
  ) {
    final entriesSnapshot =
        Map<String, AppProfileEntryData>.unmodifiable(entries);
    return _enqueueWrite(() async {
      final effectiveDefault = _latestDefaultProfile ?? defaultProfile;
      await _saveConfig(
        entriesSnapshot,
        effectiveDefault,
        screenOffProfile,
        appDebounceMs,
      );
      _latestDefaultProfile ??= effectiveDefault;
    });
  }

  /// Updates only DEFAULT_PROFILE while preserving every other setting.
  ///
  /// The read-modify-write operation shares the repository write queue so a
  /// simultaneous app-profile update cannot be overwritten by stale data.
  @override
  Future<bool> updateDefaultProfile(ProfileType profile) {
    return _enqueueWrite(() async {
      final current = await loadConfig();
      if (!current.existsOnDisk) return false;

      await _saveConfig(
        current.entries,
        profile,
        current.screenOffProfile,
        current.appDebounceMs,
      );
      _latestDefaultProfile = profile;
      return true;
    });
  }

  Future<void> _saveConfig(
    Map<String, AppProfileEntryData> entries,
    ProfileType defaultProfile,
    ProfileType screenOffProfile,
    int appDebounceMs,
  ) async {
    final tempDir = await _getTemporaryDirectory();
    final operationId = DateTime.now().microsecondsSinceEpoch;
    final tempFile = File('${tempDir.path}/app_profiles_$operationId.conf');
    final destinationTemp = '$_primaryConfigPath.$operationId.tmp';
    const q = PerfMtkShell.quote;

    try {
      final buffer = StringBuffer()
        ..writeln('# Configuration file for PerfMTK Daemon')
        ..writeln('# Format: package_name=energy_profile[;directives]')
        ..writeln()
        ..writeln(
          '# Default global profile when no application from the list is in the foreground',
        )
        ..writeln('DEFAULT_PROFILE=${defaultProfile.value}')
        ..writeln('SCREEN_OFF_PROFILE=${screenOffProfile.value}')
        ..writeln('APP_DEBOUNCE_MS=$appDebounceMs')
        ..writeln();

      final packageNames = entries.keys.toList()..sort();
      for (final packageName in packageNames) {
        final entry = entries[packageName]!;
        final confSuffix = entry.directives.toConfString();
        buffer.writeln('$packageName=${entry.profile.value}$confSuffix');
      }

      await tempFile.writeAsString(buffer.toString(), flush: true);

      await _gateway.shell(
        'cp ${q(tempFile.path)} ${q(destinationTemp)} '
        '&& chmod 644 ${q(destinationTemp)} '
        '&& mv -f ${q(destinationTemp)} ${q(_primaryConfigPath)} '
        '&& (cp -f ${q(_primaryConfigPath)} ${q(_fallbackConfigPath)} || true) '
        '&& sync '
        '&& ${PerfMtkShell.reload}',
      );
      await _notifyReload();
    } on FileSystemException catch (e) {
      throw ConfigWriteException('Error writing temp file: ${e.message}');
    } on RootShellException catch (e) {
      throw ConfigWriteException('Error copying config to destination: $e');
    } finally {
      try {
        if (await tempFile.exists()) await tempFile.delete();
      } on FileSystemException {
        // The OS will eventually clear the application cache directory.
      }
    }
  }

  @override
  Future<void> deleteConfig() {
    return _enqueueWrite(() async {
      const q = PerfMtkShell.quote;
      try {
        await _gateway.shell(
          'rm -f ${q(_primaryConfigPath)} ${q(_fallbackConfigPath)} '
          '&& sync '
          '&& ${PerfMtkShell.reload}',
        );
        await _notifyReload();
        _latestDefaultProfile = null;
      } on RootShellException catch (e) {
        throw ConfigWriteException('Error deleting config: $e');
      }
    });
  }

  /// Best-effort live reload through the daemon socket (the shell command
  /// already asked the CLI to reload, so a missing reply is not an error).
  Future<void> _notifyReload() async {
    final resp = await _gateway.ipc('RELOAD');
    if (resp == null) AppLogger.debug(_tag, 'RELOAD not acknowledged over IPC');
  }

  Future<T> _enqueueWrite<T>(Future<T> Function() operation) {
    final result = _writeQueue.then((_) => operation());
    _writeQueue = result.then((_) {}, onError: (_) {});
    return result;
  }
}
