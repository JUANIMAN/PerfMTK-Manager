import 'dart:io';
import 'package:manager/core/root_shell_manager.dart';
import 'package:manager/data/models/device_config.dart';
import 'package:manager/data/models/profile_config.dart';
import 'package:manager/data/models/profile.dart';
import 'package:path_provider/path_provider.dart';

/// Reads and writes the PerfMTK hardware + profile configuration files
/// located at /data/adb/modules/perfmtk/config/.
class PerfConfigRepository {
  static const String _configBase = '/data/adb/modules/perfmtk/config';
  static const String _deviceConfPath = '$_configBase/device.conf';
  static const String _profilesDir = '$_configBase/profiles';

  final _shell = RootShellManager();

  /// Cached flag from the last device.conf parse:
  /// true  → GPU_OPP_TABLE used  → GPU_FREQ in profile is KHz
  /// false → legacy GPU_FREQS    → GPU_FREQ in profile is Hz
  bool _gpuFreqInKHz = true;

  /// Cached GPU driver type: 'gpufreqv2' or 'gpufreq'.
  /// Determines which sentinel re-enables DVFS: -1 (v2) or 0 (legacy).
  String _gpuType = 'gpufreqv2';

  int get _gpuDvfsSentinel => _gpuType == 'gpufreqv2' ? -1 : 0;

  String _profilePath(ProfileType profile) =>
      '$_profilesDir/${profile.value}.conf';

  // ── Public API ────────────────────────────────────────────────────────────

  Future<DeviceConfig> loadDeviceConfig() async {
    try {
      final content = await _shell.executeCommand('cat $_deviceConfPath');
      final cfg = _parseDeviceConf(content);
      _gpuFreqInKHz = cfg.gpuFreqInKHz;
      _gpuType = cfg.gpuType;
      return cfg;
    } catch (e) {
      throw PerfConfigException('Failed to read device.conf: $e');
    }
  }

  Future<ProfileConfig> loadProfileConfig(ProfileType profile) async {
    try {
      final content =
          await _shell.executeCommand('cat ${_profilePath(profile)}');
      return _parseProfileConf(content);
    } catch (e) {
      throw PerfConfigException(
          'Failed to read ${profile.value}.conf: $e');
    }
  }

  Future<void> saveProfileConfig(
      ProfileType profile, ProfileConfig config) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${profile.value}.conf');

    try {
      await tempFile.writeAsString(_serialise(profile, config), flush: true);
      final dest = _profilePath(profile);
      await _shell.executeCommand(
        'cp ${tempFile.path} $dest && chmod 644 $dest && sync',
      );
    } on FileSystemException catch (e) {
      throw PerfConfigException('Error writing temp file: ${e.message}');
    } on RootShellException catch (e) {
      throw PerfConfigException('Error copying config to device: $e');
    } finally {
      if (await tempFile.exists()) await tempFile.delete();
    }
  }

  // ── device.conf parser ────────────────────────────────────────────────────

  DeviceConfig _parseDeviceConf(String content) {
    final vars = _parseKeyValueBlock(content);

    final totalPolicies = int.tryParse(vars['TOTAL_POLICIES'] ?? '0') ?? 0;
    final policies = <CpuPolicy>[];

    for (var i = 0; i < totalPolicies; i++) {
      final prefix = 'POLICY_$i';
      policies.add(CpuPolicy(
        index: i,
        path: vars['${prefix}_PATH'] ?? '',
        cpus: _parseIntList(vars['${prefix}_CPUS']),
        freqs: _parseIntList(vars['${prefix}_FREQS']),
        governors: _parseStrList(vars['${prefix}_GOVERNORS']),
        maxFreq: int.tryParse(vars['${prefix}_MAX_FREQ'] ?? '') ?? 0,
        minFreq: int.tryParse(vars['${prefix}_MIN_FREQ'] ?? '') ?? 0,
      ));
    }

    // ── GPU freqs: prefer GPU_OPP_TABLE (new, KHz), fall back to GPU_FREQS (Hz)
    List<int> gpuFreqs;
    bool gpuFreqInKHz;

    final oppTable = vars['GPU_OPP_TABLE'];
    if (oppTable != null && oppTable.isNotEmpty) {
      // Format: "0:1400000 1:1383000 ..."  values are in KHz
      gpuFreqs = _parseOppTable(oppTable);
      gpuFreqInKHz = true;
    } else {
      // Legacy: "1400000000 1383000000 ..."  values are in Hz → convert to KHz
      final hzFreqs = _parseIntList(vars['GPU_FREQS']);
      gpuFreqs = hzFreqs.map((hz) => hz ~/ 1000).toList();
      gpuFreqInKHz = false;
    }

    return DeviceConfig(
      socName: vars['SOC_NAME'] ?? 'Unknown',
      archType: vars['ARCH_TYPE'] ?? 'Unknown',
      gpuType: vars['GPU_TYPE'] ?? 'Unknown',
      totalPolicies: totalPolicies,
      policies: policies,
      gpuFreqs: gpuFreqs,
      gpuGovernors: _parseStrList(vars['GPU_GOVERNORS']),
      gpuFreqInKHz: gpuFreqInKHz,
      dvfFreqs: _parseIntList(vars['DVF_FREQS']),
      dvfGovernors: _parseStrList(vars['DVF_GOVERNORS']),
      dvfAvailable: vars['DVF_AVAILABLE']?.toLowerCase() == 'true',
      ufsFreqs: _parseIntList(vars['UFS_FREQS']),
      ufsGovernors: _parseStrList(vars['UFS_GOVERNORS']),
      ufsAvailable: vars['UFS_AVAILABLE']?.toLowerCase() == 'true',
    );
  }

  // ── profile .conf parser ─────────────────────────────────────────────────

  ProfileConfig _parseProfileConf(String content) {
    // Split into INI sections
    final sections = <String, Map<String, String>>{};
    var currentSection = '';

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      if (line.startsWith('[') && line.endsWith(']')) {
        currentSection = line.substring(1, line.length - 1);
        sections[currentSection] = {};
        continue;
      }
      if (currentSection.isEmpty) continue;

      final eq = line.indexOf('=');
      if (eq < 1) continue;
      final key = line.substring(0, eq).trim();
      var value = line.substring(eq + 1).trim();
      if (value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
      }
      sections[currentSection]![key] = value;
    }

    final cpu = sections['CPU'] ?? {};
    final gpu = sections['GPU'] ?? {};
    final devfreq = sections['DEVFREQ'] ?? {};
    final ufs = sections['UFS'] ?? {};
    final fpsgo = sections['FPSGO'] ?? {};

    // CORE_CONFIG: "cpu0:4:4|cpu4:3:2|cpu7:1:0"
    final coreConfigStr = cpu['CORE_CONFIG'] ?? '';
    final clusters = coreConfigStr
        .split('|')
        .where((s) => s.isNotEmpty)
        .map(CoreClusterConfig.fromString)
        .toList();

    // Rate limits: may be single int or space-separated list
    final downList = _parseIntList(cpu['DOWN_RATE_LIMIT_US']);
    final upList = _parseIntList(cpu['UP_RATE_LIMIT_US']);

    // GPU_FREQ: normalise the file value to our internal representation.
    // Internal: -1 always means "DVFS enabled" regardless of driver.
    // File:     -1 (gpufreqv2) or 0 (legacy gpufreq) means "DVFS enabled".
    int rawGpuFreq = int.tryParse(gpu['GPU_FREQ'] ?? '') ?? _gpuDvfsSentinel;
    if (rawGpuFreq == _gpuDvfsSentinel) {
      // Sentinel → normalise to -1 internally
      rawGpuFreq = -1;
    } else if (!_gpuFreqInKHz) {
      // Legacy Hz format → convert to KHz for internal representation
      rawGpuFreq = rawGpuFreq ~/ 1000;
    }

    return ProfileConfig(
      cpu: CpuConfig(
        governors: _parseStrList(cpu['GOVERNOR']),
        downRateLimitUs: downList.isEmpty ? [1000] : downList,
        upRateLimitUs: upList.isEmpty ? [1000] : upList,
        coreConfig: clusters,
        maxFreqs: _parseIntList(cpu['MAX_FREQS']),
        minFreqs: _parseIntList(cpu['MIN_FREQS']),
      ),
      gpu: GpuConfig(
        gpuFreq: rawGpuFreq,
        gpuGovernor: gpu['GPU_GOVERNOR'] ?? 'userspace',
      ),
      devfreq: DevfreqConfig(
        dvfGovernor: devfreq['DVF_GOVERNOR'] ?? 'userspace',
      ),
      ufs: UfsConfig(
        ufsGovernor: ufs['UFS_GOVERNOR'] ?? 'simple_ondemand',
        ufsClkEnable: int.tryParse(ufs['UFS_CLK_ENABLE'] ?? '') ?? 1,
      ),
      fpsgo: FpsgoConfig(
        forceOnOff: int.tryParse(fpsgo['FORCE_ONOFF'] ?? '') ?? 2,
        boostTa: int.tryParse(fpsgo['BOOST_TA'] ?? '') ?? 0,
      ),
    );
  }

  // ── Serialisation ─────────────────────────────────────────────────────────

  String _serialise(ProfileType profile, ProfileConfig c) {
    final title = _profileTitle(profile);
    final desc = _profileDesc(profile);

    // GPU_FREQ: convert internal representation back to the device's format.
    // Internal -1 means DVFS enabled → write the correct sentinel (0 or -1).
    final gpuFreqStr = c.gpu.gpuFreq == -1
        ? _gpuDvfsSentinel.toString()
        : (_gpuFreqInKHz
            ? c.gpu.gpuFreq.toString()
            : (c.gpu.gpuFreq * 1000).toString());

    // GPU governor: legacy devices don't expose a configurable governor.
    final gpuGovernorStr = _gpuType == 'gpufreqv2'
        ? c.gpu.gpuGovernor
        : 'none'; // Not available on this device

    final gpuComment = _gpuFreqInKHz
        ? '# GPU_FREQ: [265000 - 1400000]=(Fix GPU Frequency), $_gpuDvfsSentinel=(re-enable GPU DVFS)'
        : '# GPU_FREQ: [265000000 - 1400000000]=(Fix GPU Frequency), $_gpuDvfsSentinel=(re-enable GPU DVFS)';

    final b = StringBuffer()
      ..writeln('# $title Profile Configuration')
      ..writeln('# $desc')
      ..writeln()
      ..writeln('[CPU]')
      ..writeln('# GOVERNOR accepts one value for all policies or one value per CPU policy.')
      ..writeln('GOVERNOR="${c.cpu.governorString}"')
      ..writeln('# *_RATE_LIMIT_US accepts one value for all policies or one value per CPU policy.')
      ..writeln('DOWN_RATE_LIMIT_US="${c.cpu.downRateLimitString}"')
      ..writeln('UP_RATE_LIMIT_US="${c.cpu.upRateLimitString}"')
      ..writeln('CORE_CONFIG="${c.cpu.coreConfigString}"')
      ..writeln('MAX_FREQS="${c.cpu.maxFreqString}"')
      ..writeln('MIN_FREQS="${c.cpu.minFreqString}"')
      ..writeln()
      ..writeln('[GPU]')
      ..writeln(gpuComment)
      ..writeln('GPU_FREQ=$gpuFreqStr')
      ..writeln('GPU_GOVERNOR="$gpuGovernorStr"')
      ..writeln()
      ..writeln('[DEVFREQ]')
      ..writeln('DVF_GOVERNOR="${c.devfreq.dvfGovernor}"')
      ..writeln()
      ..writeln('[UFS]')
      ..writeln('UFS_GOVERNOR="${c.ufs.ufsGovernor}"')
      ..writeln('UFS_CLK_ENABLE=${c.ufs.ufsClkEnable}')
      ..writeln()
      ..writeln('[FPSGO]')
      ..writeln('# FORCE_ONOFF: 0=off, 1=on, 2=free(default)')
      ..writeln('FORCE_ONOFF=${c.fpsgo.forceOnOff}')
      ..writeln('BOOST_TA=${c.fpsgo.boostTa}');
    return b.toString();
  }

  String _profileTitle(ProfileType p) {
    switch (p) {
      case ProfileType.performance:
        return 'PERFORMANCE';
      case ProfileType.balanced:
        return 'BALANCED';
      case ProfileType.powersave:
        return 'POWERSAVE';
      case ProfileType.powersavePlus:
        return 'POWERSAVE+';
    }
  }

  String _profileDesc(ProfileType p) {
    switch (p) {
      case ProfileType.performance:
        return 'Maximizes performance, higher power consumption';
      case ProfileType.balanced:
        return 'Balance between performance and battery life';
      case ProfileType.powersave:
        return 'Optimizes battery life, reduced performance';
      case ProfileType.powersavePlus:
        return 'Maximum battery saving, minimal performance';
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Parses a key=value block, stripping comments and surrounding quotes.
  Map<String, String> _parseKeyValueBlock(String content) {
    final vars = <String, String>{};
    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final eq = line.indexOf('=');
      if (eq < 1) continue;
      final key = line.substring(0, eq).trim();
      var value = line.substring(eq + 1).trim();
      if (value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
      }
      vars[key] = value;
    }
    return vars;
  }

  /// Parses a GPU_OPP_TABLE string of the form "0:1400000 1:1383000 ...".
  /// Extracts the frequency (KHz) from each "index:freq" pair,
  /// and returns them sorted descending.
  List<int> _parseOppTable(String s) {
    final result = <int>[];
    for (final entry in s.trim().split(RegExp(r'\s+'))) {
      if (entry.isEmpty) continue;
      final colon = entry.indexOf(':');
      if (colon < 0) continue;
      final freq = int.tryParse(entry.substring(colon + 1));
      if (freq != null && freq > 0) result.add(freq);
    }
    result.sort((a, b) => b.compareTo(a)); // descending
    return result;
  }

  List<int> _parseIntList(String? s) {
    if (s == null || s.isEmpty) return [];
    return s
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
  }

  List<String> _parseStrList(String? s) {
    if (s == null || s.isEmpty) return [];
    return s.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  }
}

// ── Exceptions ────────────────────────────────────────────────────────────────

class PerfConfigException implements Exception {
  final String message;
  const PerfConfigException(this.message);

  @override
  String toString() => 'PerfConfigException: $message';
}
