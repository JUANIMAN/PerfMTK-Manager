import 'package:manager/data/models/device_config.dart';

/// Pure Dart parser for PerfMTK device.conf hardware definition.
class DeviceConfParser {
  const DeviceConfParser._();

  /// Parses the raw string contents of `device.conf` into a [DeviceConfig].
  static DeviceConfig parse(String content) {
    final vars = parseKeyValueBlock(content);

    final totalPolicies = int.tryParse(vars['TOTAL_POLICIES'] ?? '0') ?? 0;
    final policies = <CpuPolicy>[];
    var cumulativeCpus = 0;

    for (var i = 0; i < totalPolicies; i++) {
      final prefix = 'POLICY_$i';
      var cpus = parseIntList(vars['${prefix}_CPUS']);
      if (cpus.length == 1 && cpus.first > 1) {
        final count = cpus.first;
        cpus = List.generate(count, (idx) => cumulativeCpus + idx);
      }
      cumulativeCpus += cpus.length;

      policies.add(
        CpuPolicy(
          index: i,
          path: vars['${prefix}_PATH'] ?? '',
          cpus: cpus,
          freqs: parseIntList(vars['${prefix}_FREQS']),
          governors: parseStrList(vars['${prefix}_GOVERNORS']),
          maxFreq: int.tryParse(vars['${prefix}_MAX_FREQ'] ?? '') ?? 0,
          minFreq: int.tryParse(vars['${prefix}_MIN_FREQ'] ?? '') ?? 0,
        ),
      );
    }

    // ── GPU freqs: prefer GPU_OPP_TABLE (new, KHz), fall back to GPU_FREQS (Hz)
    List<int> gpuFreqs;
    bool gpuFreqInKHz;

    final oppTable = vars['GPU_OPP_TABLE'];
    if (oppTable != null && oppTable.isNotEmpty) {
      // Format: "0:1400000 1:1383000 ..."  values are in KHz
      gpuFreqs = parseOppTable(oppTable);
      gpuFreqInKHz = true;
    } else {
      // Legacy: "1400000000 1383000000 ..."  values are in Hz → convert to KHz
      final hzFreqs = parseIntList(vars['GPU_FREQS']);
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
      gpuGovernors: parseStrList(vars['GPU_GOVERNORS']),
      gpuFreqInKHz: gpuFreqInKHz,
      dvfFreqs: parseIntList(vars['DVF_FREQS']),
      dvfGovernors: parseStrList(vars['DVF_GOVERNORS']),
      dvfAvailable: vars['DVF_AVAILABLE']?.toLowerCase() == 'true',
      ufsFreqs: parseIntList(vars['UFS_FREQS']),
      ufsGovernors: parseStrList(vars['UFS_GOVERNORS']),
      ufsAvailable: vars['UFS_AVAILABLE']?.toLowerCase() == 'true',
      hasEas: vars['EAS_SUPPORT']?.toLowerCase() == 'true',
      hasUclamp: vars['UCLAMP_SUPPORT']?.toLowerCase() != 'false',
      hasGbe: vars['GBE_PATH'] != null && vars['GBE_PATH'] != 'none' && vars['GBE_PATH']!.isNotEmpty,
      hasChargeBypass: (vars['CHARGER_COOLING_DEV'] != null &&
              vars['CHARGER_COOLING_DEV'] != 'none' &&
              vars['CHARGER_COOLING_DEV']!.isNotEmpty) ||
          vars['HAS_CHARGE_BYPASS']?.toLowerCase() == 'true' ||
          vars['HAS_CHARGE_SUSPEND']?.toLowerCase() == 'true',
      hasHardwareBypass: vars['HAS_CHARGE_BYPASS']?.toLowerCase() == 'true',
      hasSmartFastCharge: vars['CHARGER_COOLING_DEV'] != null &&
          vars['CHARGER_COOLING_DEV'] != 'none' &&
          vars['CHARGER_COOLING_DEV']!.isNotEmpty,
      hasBatteryCare: (vars['CHARGER_COOLING_DEV'] != null &&
              vars['CHARGER_COOLING_DEV'] != 'none' &&
              vars['CHARGER_COOLING_DEV']!.isNotEmpty) ||
          (vars['BATTERY_PS_PATH'] != null && vars['BATTERY_PS_PATH'] != 'none'),
    );
  }

  /// Parses a key=value block, stripping comments and surrounding quotes.
  static Map<String, String> parseKeyValueBlock(String content) {
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
  static List<int> parseOppTable(String s) {
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

  static List<int> parseIntList(String? s) {
    if (s == null || s.isEmpty) return [];
    return s
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
  }

  static List<String> parseStrList(String? s) {
    if (s == null || s.isEmpty) return [];
    return s.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  }
}
