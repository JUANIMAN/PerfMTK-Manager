import 'dart:convert';
import 'dart:io';
import 'package:manager/core/native_ipc_channel.dart';
import 'package:manager/core/root_shell_manager.dart';
import 'package:manager/data/models/device_config.dart';
import 'package:manager/data/models/profile_config.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/parsers/device_conf_parser.dart';
import 'package:manager/data/parsers/profile_conf_parser.dart';
import 'package:path_provider/path_provider.dart';

/// Reads and writes the PerfMTK hardware + profile configuration files
/// located at /data/adb/modules/perfmtk/config/.
class PerfConfigRepository {
  static const String _configBase = '/data/adb/modules/perfmtk/config';
  static const String _deviceConfPath = '$_configBase/device.conf';
  static const String _profilesDir = '$_configBase/profiles';

  final ShellCommandExecutor _shell;
  final NativeIpcChannel _nativeIpc;

  /// Cached flag from the last device.conf parse:
  /// true  → GPU_OPP_TABLE used  → GPU_FREQ in profile is KHz
  /// false → legacy GPU_FREQS    → GPU_FREQ in profile is Hz
  bool _gpuFreqInKHz = true;

  /// Cached GPU driver type: 'gpufreqv2' or 'gpufreq'.
  String _gpuType = 'gpufreqv2';

  PerfConfigRepository({
    ShellCommandExecutor? shellManager,
    NativeIpcChannel? nativeIpc,
  })  : _shell = shellManager ?? RootShellManager(),
        _nativeIpc = nativeIpc ?? NativeIpcChannel();

  String _profilePath(ProfileType profile) =>
      '$_profilesDir/${profile.value}.conf';

  // ── Public API ────────────────────────────────────────────────────────────

  Future<DeviceConfig> loadDeviceConfig() async {
    // 1. Direct LocalSocket IPC for capabilities first (< 0.5ms)
    try {
      final capsJson = await _nativeIpc.sendCommand('CAPABILITIES_JSON');
      if (capsJson != null) {
        final trimmed = capsJson.trim();
        final start = trimmed.indexOf('{');
        final end = trimmed.lastIndexOf('}');
        if (start != -1 && end != -1 && end > start) {
          final jsonMap = jsonDecode(trimmed.substring(start, end + 1)) as Map<String, dynamic>;
          if (jsonMap.containsKey('cpu_policies') || jsonMap.containsKey('soc')) {
            final cfg = DeviceConfig.fromJson(jsonMap);
            _gpuFreqInKHz = cfg.gpuFreqInKHz;
            _gpuType = cfg.gpuType;
            return cfg;
          }
        }
      }
    } catch (_) {}

    // 2. Fallback to CLI execution
    try {
      final capsJson = await _shell.executeCommand(
        '/data/adb/modules/perfmtk/system/bin/perfmtk --caps || /data/adb/modules/perfmtk/perfmtk --caps || perfmtk --caps',
        timeout: const Duration(seconds: 4),
      );
      final trimmed = capsJson.trim();
      final start = trimmed.indexOf('{');
      final end = trimmed.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final jsonMap = jsonDecode(trimmed.substring(start, end + 1)) as Map<String, dynamic>;
        if (jsonMap.containsKey('cpu_policies') || jsonMap.containsKey('soc')) {
          final cfg = DeviceConfig.fromJson(jsonMap);
          _gpuFreqInKHz = cfg.gpuFreqInKHz;
          _gpuType = cfg.gpuType;
          return cfg;
        }
      }
    } catch (_) {
      // Fall through to device.conf reading
    }

    // 2. Fallback to reading device.conf
    try {
      final content = await _shell.executeCommand('cat $_deviceConfPath');
      var cfg = DeviceConfParser.parse(content);
      cfg = await _enrichWithSysfsIfIncomplete(cfg);
      _gpuFreqInKHz = cfg.gpuFreqInKHz;
      _gpuType = cfg.gpuType;
      return cfg;
    } catch (e) {
      throw PerfConfigException('Failed to read device configuration: $e');
    }
  }

  Future<DeviceConfig> _enrichWithSysfsIfIncomplete(DeviceConfig cfg) async {
    final needsCpuFreqs = cfg.policies.any((p) => p.freqs.isEmpty);
    final needsCpuGovs = cfg.policies.any((p) => p.governors.isEmpty);
    final needsGpuFreqs = cfg.gpuFreqs.isEmpty;
    final needsGpuGovs = cfg.gpuGovernors.isEmpty;
    final needsDvfGovs = cfg.dvfGovernors.isEmpty;
    final needsUfsGovs = cfg.ufsGovernors.isEmpty;

    if (!needsCpuFreqs &&
        !needsCpuGovs &&
        !needsGpuFreqs &&
        !needsGpuGovs &&
        !needsDvfGovs &&
        !needsUfsGovs) {
      return cfg;
    }

    // Try perfmtk --detect first if binaries exist
    try {
      final detectOut = await _shell.executeCommand(
        '/data/adb/modules/perfmtk/system/bin/perfmtk --detect 2>/dev/null '
        '|| /data/adb/modules/perfmtk/perfmtk --detect 2>/dev/null '
        '|| perfmtk --detect 2>/dev/null',
      );
      if (detectOut.contains('Hardware profile successfully written')) {
        final reloaded = await _shell.executeCommand('cat $_deviceConfPath');
        return DeviceConfParser.parse(reloaded);
      }
    } catch (_) {
      // Fall through to manual sysfs queries
    }

    final updatedPolicies = <CpuPolicy>[];
    for (final p in cfg.policies) {
      var freqs = p.freqs;
      var govs = p.governors;
      var cpus = p.cpus;

      if (freqs.isEmpty && p.path.isNotEmpty) {
        try {
          final out = await _shell.executeCommand(
            'cat ${p.path}/scaling_available_frequencies 2>/dev/null',
          );
          final parsed = DeviceConfParser.parseIntList(out);
          if (parsed.isNotEmpty) freqs = parsed;
        } catch (_) {}
      }

      if (govs.isEmpty && p.path.isNotEmpty) {
        try {
          final out = await _shell.executeCommand(
            'cat ${p.path}/scaling_available_governors 2>/dev/null',
          );
          final parsed = DeviceConfParser.parseStrList(out);
          if (parsed.isNotEmpty) govs = parsed;
        } catch (_) {}
      }

      if (cpus.length <= 1 && p.path.isNotEmpty) {
        try {
          final out = await _shell.executeCommand(
            'cat ${p.path}/affected_cpus 2>/dev/null',
          );
          final parsed = DeviceConfParser.parseIntList(out);
          if (parsed.isNotEmpty) cpus = parsed;
        } catch (_) {}
      }

      updatedPolicies.add(
        CpuPolicy(
          index: p.index,
          path: p.path,
          cpus: cpus,
          freqs: freqs,
          governors: govs.isNotEmpty
              ? govs
              : const [
                  'sugov_ext',
                  'schedutil',
                  'performance',
                  'powersave',
                  'conservative',
                ],
          maxFreq: p.maxFreq,
          minFreq: p.minFreq,
        ),
      );
    }

    var gpuFreqs = cfg.gpuFreqs;
    var gpuGovs = cfg.gpuGovernors;
    if (gpuFreqs.isEmpty || gpuGovs.isEmpty) {
      try {
        final gFreqStr = await _shell.executeCommand(
          'cat /sys/class/devfreq/*.mali/available_frequencies 2>/dev/null '
          '|| cat /sys/class/devfreq/*.gpu/available_frequencies 2>/dev/null',
        );
        final raw = DeviceConfParser.parseIntList(gFreqStr);
        if (raw.isNotEmpty) {
          gpuFreqs = raw.map((hz) => hz ~/ 1000).toList();
        }
        final gGovStr = await _shell.executeCommand(
          'cat /sys/class/devfreq/*.mali/available_governors 2>/dev/null '
          '|| cat /sys/class/devfreq/*.gpu/available_governors 2>/dev/null',
        );
        final rawGovs = DeviceConfParser.parseStrList(gGovStr);
        if (rawGovs.isNotEmpty) gpuGovs = rawGovs;
      } catch (_) {}
    }

    var dvfFreqs = cfg.dvfFreqs;
    var dvfGovs = cfg.dvfGovernors;
    if (dvfFreqs.isEmpty || dvfGovs.isEmpty) {
      try {
        final dFreqStr = await _shell.executeCommand(
          'cat /sys/class/devfreq/mtk-dvfsrc-devfreq/available_frequencies 2>/dev/null',
        );
        final raw = DeviceConfParser.parseIntList(dFreqStr);
        if (raw.isNotEmpty) dvfFreqs = raw;

        final dGovStr = await _shell.executeCommand(
          'cat /sys/class/devfreq/mtk-dvfsrc-devfreq/available_governors 2>/dev/null',
        );
        final rawGovs = DeviceConfParser.parseStrList(dGovStr);
        if (rawGovs.isNotEmpty) dvfGovs = rawGovs;
      } catch (_) {}
    }

    var ufsFreqs = cfg.ufsFreqs;
    var ufsGovs = cfg.ufsGovernors;
    if (ufsFreqs.isEmpty || ufsGovs.isEmpty) {
      try {
        final uFreqStr = await _shell.executeCommand(
          'cat /sys/class/devfreq/*.ufshci/available_frequencies 2>/dev/null',
        );
        final raw = DeviceConfParser.parseIntList(uFreqStr);
        if (raw.isNotEmpty) ufsFreqs = raw;

        final uGovStr = await _shell.executeCommand(
          'cat /sys/class/devfreq/*.ufshci/available_governors 2>/dev/null',
        );
        final rawGovs = DeviceConfParser.parseStrList(uGovStr);
        if (rawGovs.isNotEmpty) ufsGovs = rawGovs;
      } catch (_) {}
    }

    return DeviceConfig(
      socName: cfg.socName,
      archType: cfg.archType,
      gpuType: cfg.gpuType,
      totalPolicies: cfg.totalPolicies,
      policies: updatedPolicies,
      gpuFreqs: gpuFreqs,
      gpuGovernors: gpuGovs.isNotEmpty
          ? gpuGovs
          : const ['simple_ondemand', 'performance', 'powersave', 'userspace'],
      gpuFreqInKHz: cfg.gpuFreqInKHz,
      dvfFreqs: dvfFreqs,
      dvfGovernors: dvfGovs.isNotEmpty
          ? dvfGovs
          : const ['simple_ondemand', 'performance', 'powersave', 'userspace'],
      dvfAvailable: cfg.dvfAvailable,
      ufsFreqs: ufsFreqs,
      ufsGovernors: ufsGovs.isNotEmpty
          ? ufsGovs
          : const ['simple_ondemand', 'performance', 'powersave', 'userspace'],
      ufsAvailable: cfg.ufsAvailable,
    );
  }

  Future<ProfileConfig> loadProfileConfig(ProfileType profile) async {
    try {
      final content = await _shell.executeCommand(
        'cat ${_profilePath(profile)}',
      );
      return ProfileConfParser.parse(
        content,
        gpuFreqInKHz: _gpuFreqInKHz,
        gpuType: _gpuType,
      );
    } catch (e) {
      throw PerfConfigException('Failed to read ${profile.value}.conf: $e');
    }
  }

  Future<void> saveProfileConfig(
    ProfileType profile,
    ProfileConfig config,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final operationId = DateTime.now().microsecondsSinceEpoch;
    final tempFile = File('${tempDir.path}/${profile.value}_$operationId.conf');
    final dest = _profilePath(profile);
    final destinationTemp = '$dest.$operationId.tmp';

    try {
      final serialized = ProfileConfParser.serialize(
        profile,
        config,
        gpuFreqInKHz: _gpuFreqInKHz,
        gpuType: _gpuType,
      );
      await tempFile.writeAsString(serialized, flush: true);
      await _shell.executeCommand(
        'cp ${_shellQuote(tempFile.path)} ${_shellQuote(destinationTemp)} '
        '&& chmod 644 ${_shellQuote(destinationTemp)} '
        '&& mv -f ${_shellQuote(destinationTemp)} ${_shellQuote(dest)} '
        '&& sync '
        '&& (/data/adb/modules/perfmtk/system/bin/perfmtk --reload || /data/adb/modules/perfmtk/perfmtk --reload || /data/adb/ksu/bin/perfmtk --reload || perfmtk --reload || true)',
      );
      try {
        await _nativeIpc.sendCommand('RELOAD');
      } catch (_) {}
    } on FileSystemException catch (e) {
      throw PerfConfigException('Error writing temp file: ${e.message}');
    } on RootShellException catch (e) {
      throw PerfConfigException('Error copying config to device: $e');
    } finally {
      try {
        if (await tempFile.exists()) await tempFile.delete();
      } on FileSystemException {
        // The OS will eventually clear the application cache directory.
      }
    }
  }

  String _shellQuote(String value) {
    final escaped = value
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll(r'$', r'\$')
        .replaceAll(String.fromCharCode(96), r'\`');
    return '"$escaped"';
  }
}

// ── Exceptions ────────────────────────────────────────────────────────────────

class PerfConfigException implements Exception {
  final String message;
  const PerfConfigException(this.message);

  @override
  String toString() => 'PerfConfigException: $message';
}
