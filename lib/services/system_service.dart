import 'dart:io';
import 'package:flutter/foundation.dart';

class SystemService extends ChangeNotifier {
  String _currentProfile = '';
  String _currentThermal = '';
  String get currentProfile => _currentProfile;
  String get currentThermal => _currentThermal;

  SystemService() {
    _initCurrentProfile();
    _initCurrentThermal();
  }

  Future<void> _initCurrentProfile() async {
    _currentProfile = await getCurrentProfile();
    notifyListeners();
  }

  Future<void> _initCurrentThermal() async {
    _currentThermal = await getCurrentThermal();
    notifyListeners();
  }

  Future<String> runCommand(String command, List<String> arguments) async {
    try {
      final result = await Process.run(command, arguments);
      if (result.exitCode != 0) {
        throw Exception('Command failed: ${result.stderr}');
      }
      return result.stdout.trim();
    } catch (e) {
      throw Exception('Failed to run command: $e');
    }
  }

  Future<String> getCurrentProfile() async {
    return runCommand('getprop', ['sys.perfmtk.current_profile']);
  }

  Future<void> setProfile(String profile) async {
    await runCommand('su', ['-c', 'perfmtk', profile]);
    _currentProfile = await getCurrentProfile();
    notifyListeners();
  }

  Future<String> getCurrentThermal() async {
    return runCommand('getprop', ['sys.perfmtk.thermal_state']);
  }

  Future<void> setThermal(String thermal) async {
    await runCommand('su', ['-c', 'thermal_limit', thermal]);
    _currentThermal = await getCurrentThermal();
    notifyListeners();
  }
}
