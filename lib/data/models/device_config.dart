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
  });

  /// Fallback config used when device.conf cannot be read.
  factory DeviceConfig.empty() {
    return const DeviceConfig(
      socName: 'Unknown',
      archType: 'Unknown',
      gpuType: 'Unknown',
      totalPolicies: 0,
      policies: [],
      gpuFreqs: [],
      gpuGovernors: ['userspace', 'performance', 'powersave', 'simple_ondemand'],
      gpuFreqInKHz: true,
      dvfFreqs: [],
      dvfGovernors: ['userspace', 'performance', 'powersave', 'simple_ondemand'],
      dvfAvailable: true,
      ufsFreqs: [],
      ufsGovernors: ['simple_ondemand', 'userspace', 'performance', 'powersave'],
      ufsAvailable: true,
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

