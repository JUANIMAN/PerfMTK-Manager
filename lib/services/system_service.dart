import 'dart:io' show Process;
import 'package:flutter/material.dart';

class SystemService with ChangeNotifier {
  String _currentProfile = '';
  String _currentThermal = '';
  bool _isInitialized = false;

  String get currentProfile => _currentProfile;
  String get currentThermal => _currentThermal;
  bool get isInitialized => _isInitialized;

  SystemService() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Future.wait([
        _initCurrentProfile(),
        _initCurrentThermal(),
      ]);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize SystemService: $e');
    }
  }

  Future<void> _initCurrentProfile() async {
    _currentProfile = await getCurrentProfile();
  }

  Future<void> _initCurrentThermal() async {
    _currentThermal = await getCurrentThermal();
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
    _currentProfile = profile;
    notifyListeners();
  }

  Future<String> getCurrentThermal() async {
    return runCommand('getprop', ['sys.perfmtk.thermal_state']);
  }

  Future<void> setThermal(String thermal) async {
    await runCommand('su', ['-c', 'thermal_limit', thermal]);
    _currentThermal = thermal;
    notifyListeners();
  }
}
