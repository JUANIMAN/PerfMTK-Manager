import 'dart:io';
import 'package:manager/core/errors/app_exception.dart';
import 'package:manager/core/logging/app_logger.dart';
import 'package:manager/core/platform/daemon_gateway.dart';
import 'package:manager/core/platform/perfmtk_paths.dart';
import 'package:manager/features/perf_config/data/device_config.dart';
import 'package:manager/features/perf_config/data/profile_config.dart';
import 'package:manager/features/system/data/models/profile.dart';
import 'package:manager/features/perf_config/data/device_conf_parser.dart';
import 'package:manager/features/perf_config/data/profile_conf_parser.dart';
import 'package:path_provider/path_provider.dart';

/// Reads and writes the PerfMTK hardware + profile configuration files
/// located at /data/adb/modules/perfmtk/config/.
class PerfConfigRepository {
  static const String _tag = 'PerfConfigRepository';
  static const List<String> _defaultDevfreqGovernors = [
    'simple_ondemand',
    'performance',
    'powersave',
    'userspace',
  ];
  static const List<String> _defaultCpuGovernors = [
    'sugov_ext',
    'schedutil',
    'performance',
    'powersave',
    'conservative',
  ];

  final DaemonGateway _gateway;
  final Future<Directory> Function() _getTemporaryDirectory;

  /// Cached flag from the last device.conf parse:
  /// true  → GPU_OPP_TABLE used  → GPU_FREQ in profile is KHz
  /// false → legacy GPU_FREQS    → GPU_FREQ in profile is Hz
  bool _gpuFreqInKHz = true;

  /// Cached GPU driver type: 'gpufreqv2' or 'gpufreq'.
  String _gpuType = 'gpufreqv2';

  PerfConfigRepository({
    required DaemonGateway gateway,
    Future<Directory> Function()? getTempDirectory,
  }) : _gateway = gateway,
       _getTemporaryDirectory = getTempDirectory ?? getTemporaryDirectory;

  // ── Public API ────────────────────────────────────────────────────────────

  Future<DeviceConfig> loadDeviceConfig() async {
    // 1. Direct LocalSocket IPC for capabilities first (< 0.5ms)
    final ipcCaps = await _gateway.ipcJson('CAPABILITIES_JSON');
    final fromIpc = _capsToConfig(ipcCaps);
    if (fromIpc != null) return fromIpc;

    // 2. Fallback to CLI execution
    final shellCaps = await _gateway.shellJson(
      PerfMtkShell.cliChain('--caps'),
      timeout: const Duration(seconds: 4),
    );
    final fromShell = _capsToConfig(shellCaps);
    if (fromShell != null) return fromShell;

    // 3. Fallback to reading device.conf
    try {
      final content = await _gateway.shell('cat ${PerfMtkPaths.deviceConf}');
      var cfg = DeviceConfParser.parse(content);
      cfg = await _enrichWithSysfsIfIncomplete(cfg);
      return _remember(cfg);
    } on Exception catch (e) {
      throw PerfConfigException('Failed to read device configuration: $e');
    }
  }

  Future<ProfileConfig> loadProfileConfig(ProfileType profile) async {
    try {
      final content = await _gateway.shell(
        'cat ${PerfMtkPaths.profileConf(profile.value)}',
      );
      return ProfileConfParser.parse(
        content,
        gpuFreqInKHz: _gpuFreqInKHz,
        gpuType: _gpuType,
      );
    } on Exception catch (e) {
      throw PerfConfigException('Failed to read ${profile.value}.conf: $e');
    }
  }

  Future<void> saveProfileConfig(
    ProfileType profile,
    ProfileConfig config,
  ) async {
    final tempDir = await _getTemporaryDirectory();
    final operationId = DateTime.now().microsecondsSinceEpoch;
    final tempFile = File('${tempDir.path}/${profile.value}_$operationId.conf');
    final dest = PerfMtkPaths.profileConf(profile.value);
    final destinationTemp = '$dest.$operationId.tmp';
    const q = PerfMtkShell.quote;

    try {
      final serialized = ProfileConfParser.serialize(
        profile,
        config,
        gpuFreqInKHz: _gpuFreqInKHz,
        gpuType: _gpuType,
      );
      await tempFile.writeAsString(serialized, flush: true);
      await _gateway.shell(
        'cp ${q(tempFile.path)} ${q(destinationTemp)} '
        '&& chmod 644 ${q(destinationTemp)} '
        '&& mv -f ${q(destinationTemp)} ${q(dest)} '
        '&& sync '
        '&& ${PerfMtkShell.reload}',
      );
      final resp = await _gateway.ipc('RELOAD');
      if (resp == null) {
        AppLogger.debug(_tag, 'RELOAD not acknowledged over IPC');
      }
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

  // ── Device config helpers ─────────────────────────────────────────────────

  /// Returns a config only when the payload looks like a capabilities report.
  DeviceConfig? _capsToConfig(Map<String, dynamic>? json) {
    if (json == null) return null;
    if (!json.containsKey('cpu_policies') && !json.containsKey('soc')) {
      return null;
    }
    try {
      return _remember(DeviceConfig.fromJson(json));
    } on TypeError catch (e) {
      AppLogger.warn(_tag, 'unexpected capabilities payload shape', e);
      return null;
    }
  }

  DeviceConfig _remember(DeviceConfig cfg) {
    _gpuFreqInKHz = cfg.gpuFreqInKHz;
    _gpuType = cfg.gpuType;
    return cfg;
  }

  /// Runs a best-effort read; null when the command fails.
  Future<String?> _tryShell(String command) async {
    try {
      return await _gateway.shell(command);
    } on RootShellException catch (e) {
      AppLogger.debug(_tag, 'optional read failed: $e');
      return null;
    }
  }

  Future<List<int>?> _tryIntList(String command) async {
    final out = await _tryShell(command);
    if (out == null) return null;
    final parsed = DeviceConfParser.parseIntList(out);
    return parsed.isEmpty ? null : parsed;
  }

  Future<List<String>?> _tryStrList(String command) async {
    final out = await _tryShell(command);
    if (out == null) return null;
    final parsed = DeviceConfParser.parseStrList(out);
    return parsed.isEmpty ? null : parsed;
  }

  Future<DeviceConfig> _enrichWithSysfsIfIncomplete(DeviceConfig cfg) async {
    final isComplete =
        cfg.policies.every((p) => p.freqs.isNotEmpty && p.governors.isNotEmpty) &&
        cfg.gpuFreqs.isNotEmpty &&
        cfg.gpuGovernors.isNotEmpty &&
        cfg.dvfGovernors.isNotEmpty &&
        cfg.ufsGovernors.isNotEmpty;
    if (isComplete) return cfg;

    // Try perfmtk --detect first if binaries exist
    final detectOut = await _tryShell(
      PerfMtkShell.cliChain('--detect 2>/dev/null'),
    );
    if (detectOut != null &&
        detectOut.contains('Hardware profile successfully written')) {
      final reloaded = await _tryShell('cat ${PerfMtkPaths.deviceConf}');
      if (reloaded != null) return DeviceConfParser.parse(reloaded);
    }

    final updatedPolicies = <CpuPolicy>[];
    for (final p in cfg.policies) {
      var freqs = p.freqs;
      var govs = p.governors;
      var cpus = p.cpus;

      if (p.path.isNotEmpty) {
        if (freqs.isEmpty) {
          freqs =
              await _tryIntList(
                'cat ${p.path}/scaling_available_frequencies 2>/dev/null',
              ) ??
              freqs;
        }
        if (govs.isEmpty) {
          govs =
              await _tryStrList(
                'cat ${p.path}/scaling_available_governors 2>/dev/null',
              ) ??
              govs;
        }
        if (cpus.length <= 1) {
          cpus =
              await _tryIntList('cat ${p.path}/affected_cpus 2>/dev/null') ??
              cpus;
        }
      }

      updatedPolicies.add(
        CpuPolicy(
          index: p.index,
          path: p.path,
          cpus: cpus,
          freqs: freqs,
          governors: govs.isNotEmpty ? govs : _defaultCpuGovernors,
          maxFreq: p.maxFreq,
          minFreq: p.minFreq,
        ),
      );
    }

    var gpuFreqs = cfg.gpuFreqs;
    var gpuGovs = cfg.gpuGovernors;
    if (gpuFreqs.isEmpty || gpuGovs.isEmpty) {
      final raw = await _tryIntList(
        'cat /sys/class/devfreq/*.mali/available_frequencies 2>/dev/null '
        '|| cat /sys/class/devfreq/*.gpu/available_frequencies 2>/dev/null',
      );
      if (raw != null) gpuFreqs = raw.map((hz) => hz ~/ 1000).toList();
      gpuGovs =
          await _tryStrList(
            'cat /sys/class/devfreq/*.mali/available_governors 2>/dev/null '
            '|| cat /sys/class/devfreq/*.gpu/available_governors 2>/dev/null',
          ) ??
          gpuGovs;
    }

    var dvfFreqs = cfg.dvfFreqs;
    var dvfGovs = cfg.dvfGovernors;
    if (dvfFreqs.isEmpty || dvfGovs.isEmpty) {
      const base = '/sys/class/devfreq/mtk-dvfsrc-devfreq';
      dvfFreqs =
          await _tryIntList('cat $base/available_frequencies 2>/dev/null') ??
          dvfFreqs;
      dvfGovs =
          await _tryStrList('cat $base/available_governors 2>/dev/null') ??
          dvfGovs;
    }

    var ufsFreqs = cfg.ufsFreqs;
    var ufsGovs = cfg.ufsGovernors;
    if (ufsFreqs.isEmpty || ufsGovs.isEmpty) {
      const base = '/sys/class/devfreq/*.ufshci';
      ufsFreqs =
          await _tryIntList('cat $base/available_frequencies 2>/dev/null') ??
          ufsFreqs;
      ufsGovs =
          await _tryStrList('cat $base/available_governors 2>/dev/null') ??
          ufsGovs;
    }

    return DeviceConfig(
      socName: cfg.socName,
      archType: cfg.archType,
      gpuType: cfg.gpuType,
      totalPolicies: cfg.totalPolicies,
      policies: updatedPolicies,
      gpuFreqs: gpuFreqs,
      gpuGovernors: gpuGovs.isNotEmpty ? gpuGovs : _defaultDevfreqGovernors,
      gpuFreqInKHz: cfg.gpuFreqInKHz,
      dvfFreqs: dvfFreqs,
      dvfGovernors: dvfGovs.isNotEmpty ? dvfGovs : _defaultDevfreqGovernors,
      dvfAvailable: cfg.dvfAvailable,
      ufsFreqs: ufsFreqs,
      ufsGovernors: ufsGovs.isNotEmpty ? ufsGovs : _defaultDevfreqGovernors,
      ufsAvailable: cfg.ufsAvailable,
      hasEas: cfg.hasEas,
      hasUclamp: cfg.hasUclamp,
      hasGbe: cfg.hasGbe,
      hasFpsgo: cfg.hasFpsgo,
      hasChargeBypass: cfg.hasChargeBypass,
      hasHardwareBypass: cfg.hasHardwareBypass,
      hasSmartFastCharge: cfg.hasSmartFastCharge,
      hasBatteryCare: cfg.hasBatteryCare,
    );
  }
}
