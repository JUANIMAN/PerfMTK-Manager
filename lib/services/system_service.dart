import 'dart:io';

class SystemService {
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
  }

  Future<String> getThermalState() async {
    return runCommand('getprop', ['sys.perfmtk.thermal_state']);
  }

  Future<void> setThermalLimit(String thermal) async {
    await runCommand('su', ['-c', 'thermal_limit', thermal]);
  }
}