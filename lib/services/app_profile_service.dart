import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:path_provider/path_provider.dart';

class AppProfileService with ChangeNotifier {
  List<Application> _installedApps = [];
  final Map<String, String> _appProfiles = {};
  String _defaultProfile = 'balanced';
  final String _configFilePath = '/data/adb/modules/perfmtk/app_profiles.conf';
  bool _configExists = false;
  bool _appsLoaded = false;

  List<Application> get installedApps => _installedApps;
  String get defaultProfile => _defaultProfile;
  bool get configExists => _configExists;

  // Función para verificar si el archivo de configuración existe
  Future<bool> checkConfigExists() async {
    try {
      final result = await Process.run('su', ['-c', 'test -f $_configFilePath && echo "exists" || echo "not exists"']);
      _configExists = result.stdout.toString().trim() == 'exists';
      return _configExists;
    } catch (e) {
      debugPrint('Failed to check if config file exists: $e');
      _configExists = false;
      return false;
    }
  }

  // Inicializar el servicio y verficar si el archivo de configuración existe
  Future<void> initialize() async {
    await checkConfigExists();
    notifyListeners();
  }

  Future<void> loadInstalledApps({bool forceReload = false}) async {
    if (_appsLoaded && !forceReload) {
      return;
    }

    try {
      final apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: false,
        onlyAppsWithLaunchIntent: true,
      );

      // Ordenar aplicaciones por nombre
      apps.sort((a, b) => a.appName.compareTo(b.appName));

      _installedApps = apps;
      _appsLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load installed apps: $e');
    }
  }

  Future<void> loadAppProfiles() async {
    try {
      // Verificar si el archivo de configuración existe
      final configExists = await checkConfigExists();
      if (!configExists) {
        // Crear archivo de configuración predeterminado, si este no existe
        await _saveAppProfiles();
        return;
      }

      // Leer el archivo de configuración usando root
      final catResult = await Process.run('su', ['-c', 'cat $_configFilePath']);
      if (catResult.exitCode != 0) {
        throw Exception('Failed to read config file: ${catResult.stderr}');
      }

      final lines = catResult.stdout.toString().split('\n');
      _appProfiles.clear();

      for (final line in lines) {
        if (line.trim().isEmpty || line.startsWith('#')) {
          continue;
        }

        if (line.startsWith('DEFAULT_PROFILE')) {
          final parts = line.split('=');
          if (parts.length == 2) {
            _defaultProfile = parts[1].trim();
          }
          continue;
        }

        final parts = line.split('=');
        if (parts.length == 2) {
          final packageName = parts[0].trim();
          final profile = parts[1].trim();
          _appProfiles[packageName] = profile;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load app profiles: $e');
    }
  }

  Future<void> _saveAppProfiles() async {
    try {
      // Crear archivo temporal en el directorio de apps
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/app_profiles.conf');

      final buffer = StringBuffer();

      // Escribir encabezado
      buffer.writeln('# Configuration file for PerfMTK Daemon');
      buffer.writeln('# Format: package_name=energy_profile');
      buffer.writeln();
      buffer.writeln('# Default global profile when no application from the list is in the foreground');
      buffer.writeln('DEFAULT_PROFILE=$_defaultProfile');
      buffer.writeln();

      // Escribir perfiles de aplicación
      _appProfiles.forEach((packageName, profile) {
        if (packageName != 'DEFAULT_PROFILE') {
          buffer.writeln('$packageName=$profile');
        }
      });

      // Escribir en el archivo temporal
      await tempFile.writeAsString(buffer.toString());

      // Copiar a la ruta correcta usando root
      final result = await Process.run('su', [
        '-c',
        'cp ${tempFile.path} $_configFilePath && chmod 644 $_configFilePath'
      ]);

      if (result.exitCode != 0) {
        throw Exception('Failed to save config file: ${result.stderr}');
      }

      // Limpiar archivo temporal
      await tempFile.delete();

      _configExists = true;

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save app profiles: $e');
      rethrow;
    }
  }

  String getAppProfile(String packageName) {
    return _appProfiles[packageName] ?? '';
  }

  Future<void> setAppProfile(String packageName, String profile) async {
    if (profile.isEmpty) {
      _appProfiles.remove(packageName);
    } else {
      _appProfiles[packageName] = profile;
    }

    await _saveAppProfiles();
    notifyListeners();
  }

  Future<void> setDefaultProfile(String profile) async {
    _defaultProfile = profile;
    await _saveAppProfiles();
    notifyListeners();
  }
}

