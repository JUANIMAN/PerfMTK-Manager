/// Represents a single CPU frequency policy (cluster).
class CpuPolicy {
  final int index;
  final String path;

  /// Core numbers belonging to this cluster (e.g. [0, 1, 2, 3]).
  final List<int> cpus;

  /// Available frequencies in KHz, sorted descending.
  final List<int> freqs;

  /// Available governor names.
  final List<String> governors;

  /// Maximum frequency in KHz (hardware cap).
  final int maxFreq;

  /// Minimum frequency in KHz (hardware floor).
  final int minFreq;

  const CpuPolicy({
    required this.index,
    required this.path,
    required this.cpus,
    required this.freqs,
    required this.governors,
    required this.maxFreq,
    required this.minFreq,
  });

  /// Human-readable cluster name.
  String get clusterName {
    switch (index) {
      case 0:
        return 'Little Cluster';
      case 1:
        return 'Mid Cluster';
      case 2:
        return 'Prime Cluster';
      default:
        return 'Cluster $index';
    }
  }

  /// Short CPU range label, e.g. "cpu0-3" or "cpu7".
  String get cpuLabel {
    if (cpus.isEmpty) return '';
    if (cpus.length == 1) return 'cpu${cpus.first}';
    return 'cpu${cpus.first}-${cpus.last}';
  }
}

/// Full hardware description parsed from
/// `/data/adb/modules/perfmtk/config/device.conf`.
class DeviceConfig {
  final String socName;
  final String archType;
  final String gpuType;
  final int totalPolicies;

  /// CPU frequency policies (one per cluster).
  final List<CpuPolicy> policies;

  /// GPU available frequencies in **KHz**, sorted descending.
  /// Extracted from GPU_OPP_TABLE (new) or GPU_FREQS converted (legacy).
  final List<int> gpuFreqs;
  final List<String> gpuGovernors;

  /// True when device.conf uses GPU_OPP_TABLE (KHz unit for GPU_FREQ in
  /// profile configs). False when it uses legacy GPU_FREQS (Hz unit).
  final bool gpuFreqInKHz;

  /// DRAM DVFS available frequencies in Hz, sorted ascending.
  final List<int> dvfFreqs;
  final List<String> dvfGovernors;
  final bool dvfAvailable;

  /// UFS available frequencies in Hz.
  final List<int> ufsFreqs;
  final List<String> ufsGovernors;
  final bool ufsAvailable;

  /// Hardware feature capabilities detected by daemon/CLI
  final bool hasEas;
  final bool hasUclamp;
  final bool hasGbe;
  final bool hasFpsgo;
  final bool hasChargeBypass;
  final bool hasBatteryCare;

  const DeviceConfig({
    required this.socName,
    required this.archType,
    required this.gpuType,
    required this.totalPolicies,
    required this.policies,
    required this.gpuFreqs,
    required this.gpuGovernors,
    this.gpuFreqInKHz = true,
    required this.dvfFreqs,
    required this.dvfGovernors,
    this.dvfAvailable = true,
    required this.ufsFreqs,
    required this.ufsGovernors,
    this.ufsAvailable = true,
    this.hasEas = true,
    this.hasUclamp = true,
    this.hasGbe = false,
    this.hasFpsgo = false,
    this.hasChargeBypass = false,
    this.hasBatteryCare = false,
  });

  /// Creates a [DeviceConfig] directly from the JSON returned by
  /// `perfmtk --caps --json` (CAPABILITIES_JSON endpoint).
  factory DeviceConfig.fromJson(Map<String, dynamic> json) {
    final soc = json['soc'] as Map<String, dynamic>? ?? {};
    final features = json['features'] as Map<String, dynamic>? ?? {};
    final gpu = json['gpu'] as Map<String, dynamic>? ?? {};
    final dram = json['dram'] as Map<String, dynamic>? ?? {};
    final ufs = json['ufs'] as Map<String, dynamic>? ?? {};
    final policiesList = json['cpu_policies'] as List<dynamic>? ?? [];

    final policies = <CpuPolicy>[];
    for (var i = 0; i < policiesList.length; i++) {
      final p = policiesList[i] as Map<String, dynamic>;
      final cpus = (p['cpus'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [];
      final freqs = (p['available_freqs'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [];
      final govs = (p['available_governors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      policies.add(
        CpuPolicy(
          index: (p['id'] as num?)?.toInt() ?? i,
          path: p['path']?.toString() ?? '',
          cpus: cpus,
          freqs: freqs,
          governors: govs,
          maxFreq: (p['max_freq'] as num?)?.toInt() ??
              (freqs.isNotEmpty ? freqs.first : 0),
          minFreq: (p['min_freq'] as num?)?.toInt() ??
              (freqs.isNotEmpty ? freqs.last : 0),
        ),
      );
    }

    final gpuFreqs = (gpu['available_freqs'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        [];
    final gpuGovs = (gpu['available_governors'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final dramFreqs = (dram['available_freqs'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        [];
    final dramGovs = (dram['available_governors'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final ufsFreqs = (ufs['available_freqs'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        [];
    final ufsGovs = (ufs['available_governors'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return DeviceConfig(
      socName: soc['name']?.toString() ?? 'Unknown',
      archType: soc['arch']?.toString() ?? 'Unknown',
      gpuType:
          gpu['type']?.toString() ?? soc['gpu_type']?.toString() ?? 'Unknown',
      totalPolicies:
          (json['total_policies'] as num?)?.toInt() ?? policies.length,
      policies: policies,
      gpuFreqs: gpuFreqs,
      gpuGovernors: gpuGovs,
      gpuFreqInKHz: true,
      dvfFreqs: dramFreqs,
      dvfGovernors: dramGovs,
      dvfAvailable:
          dram['available'] as bool? ??
          (features['dram_dvfs'] as bool? ?? true),
      ufsFreqs: ufsFreqs,
      ufsGovernors: ufsGovs,
      ufsAvailable:
          ufs['available'] as bool? ?? (features['ufs'] as bool? ?? true),
      hasEas: features['eas'] as bool? ?? true,
      hasUclamp: features['uclamp'] as bool? ?? true,
      hasGbe: features['gbe'] as bool? ?? false,
      hasFpsgo: features['fpsgo'] as bool? ?? false,
      hasChargeBypass: features['charge_bypass'] as bool? ?? false,
      hasBatteryCare: features['battery_care'] as bool? ?? false,
    );
  }

  /// Fallback config used when device.conf cannot be read.
  factory DeviceConfig.empty() {
    return const DeviceConfig(
      socName: 'Unknown',
      archType: 'Unknown',
      gpuType: 'Unknown',
      totalPolicies: 0,
      policies: [],
      gpuFreqs: [],
      gpuGovernors: [
        'userspace',
        'performance',
        'powersave',
        'simple_ondemand',
      ],
      gpuFreqInKHz: true,
      dvfFreqs: [],
      dvfGovernors: [
        'userspace',
        'performance',
        'powersave',
        'simple_ondemand',
      ],
      dvfAvailable: true,
      ufsFreqs: [],
      ufsGovernors: [
        'simple_ondemand',
        'userspace',
        'performance',
        'powersave',
      ],
      ufsAvailable: true,
      hasEas: true,
      hasUclamp: true,
      hasGbe: false,
      hasFpsgo: false,
      hasChargeBypass: false,
      hasBatteryCare: false,
    );
  }

  // ── Computed helpers ───────────────────────────────────────────────────────

  /// The GPU_FREQ value that means "re-enable DVFS" in profile .conf files.
  ///   • gpufreqv2 driver → **-1**
  ///   • legacy gpufreq driver → **0**
  int get gpuDvfsSentinel => gpuType == 'gpufreqv2' ? -1 : 0;

  /// True when this device exposes a configurable GPU governor.
  /// Legacy gpufreq devices write `GPU_GOVERNOR="none"`.
  bool get gpuHasGovernor => gpuGovernors.isNotEmpty &&
      !(gpuGovernors.length == 1 && gpuGovernors.first == 'none');
}

