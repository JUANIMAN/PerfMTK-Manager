// ── Core cluster config ───────────────────────────────────────────────────────

/// One entry in the CORE_CONFIG string, e.g. "cpu0:4:4".
class CoreClusterConfig {
  /// CPU id string, e.g. "cpu0", "cpu4", "cpu7".
  final String cpuId;

  /// Total cores in this cluster.
  final int totalCores;

  /// Cores kept online for this profile.
  final int onlineCores;

  const CoreClusterConfig({
    required this.cpuId,
    required this.totalCores,
    required this.onlineCores,
  });

  CoreClusterConfig copyWith({int? onlineCores}) {
    return CoreClusterConfig(
      cpuId: cpuId,
      totalCores: totalCores,
      onlineCores: (onlineCores ?? this.onlineCores).clamp(0, totalCores),
    );
  }

  /// Serialises back to "cpu0:4:4" format.
  String toConf() => '$cpuId:$totalCores:$onlineCores';

  /// Parses from "cpu0:4:4" format.
  static CoreClusterConfig fromString(String s) {
    final parts = s.split(':');
    if (parts.length < 3) {
      return CoreClusterConfig(cpuId: s, totalCores: 1, onlineCores: 1);
    }
    return CoreClusterConfig(
      cpuId: parts[0],
      totalCores: int.tryParse(parts[1]) ?? 1,
      onlineCores: int.tryParse(parts[2]) ?? 1,
    );
  }
}

// ── CPU config ────────────────────────────────────────────────────────────────

class CpuConfig {
  /// One governor name per policy cluster (space-separated in the file).
  final List<String> governors;

  /// Scheduler rate-limit in microseconds, one value per policy.
  /// A single value may be broadcast to all policies on older devices.
  final List<int> downRateLimitUs;
  final List<int> upRateLimitUs;
  final List<CoreClusterConfig> coreConfig;

  /// Maximum frequency per policy in KHz.
  final List<int> maxFreqs;

  /// Minimum frequency per policy in KHz.
  final List<int> minFreqs;

  const CpuConfig({
    required this.governors,
    required this.downRateLimitUs,
    required this.upRateLimitUs,
    required this.coreConfig,
    required this.maxFreqs,
    required this.minFreqs,
  });

  CpuConfig copyWith({
    List<String>? governors,
    List<int>? downRateLimitUs,
    List<int>? upRateLimitUs,
    List<CoreClusterConfig>? coreConfig,
    List<int>? maxFreqs,
    List<int>? minFreqs,
  }) {
    return CpuConfig(
      governors: governors ?? this.governors,
      downRateLimitUs: downRateLimitUs ?? this.downRateLimitUs,
      upRateLimitUs: upRateLimitUs ?? this.upRateLimitUs,
      coreConfig: coreConfig ?? this.coreConfig,
      maxFreqs: maxFreqs ?? this.maxFreqs,
      minFreqs: minFreqs ?? this.minFreqs,
    );
  }

  // ── Serialisation helpers ─────────────────────────────────────────────────

  String get governorString => governors.join(' ');
  String get maxFreqString => maxFreqs.join(' ');
  String get minFreqString => minFreqs.join(' ');
  String get coreConfigString => coreConfig.map((c) => c.toConf()).join('|');
  String get downRateLimitString => downRateLimitUs.join(' ');
  String get upRateLimitString => upRateLimitUs.join(' ');
}

// ── GPU config ────────────────────────────────────────────────────────────────

class GpuConfig {
  /// Fixed GPU frequency in Hz, or -1 to let the driver choose (DVFS enabled).
  final int gpuFreq;
  final String gpuGovernor;

  const GpuConfig({required this.gpuFreq, required this.gpuGovernor});

  bool get isDvfsEnabled => gpuFreq == -1;

  GpuConfig copyWith({int? gpuFreq, String? gpuGovernor}) {
    return GpuConfig(
      gpuFreq: gpuFreq ?? this.gpuFreq,
      gpuGovernor: gpuGovernor ?? this.gpuGovernor,
    );
  }
}

// ── DEVFREQ config ────────────────────────────────────────────────────────────

class DevfreqConfig {
  final String dvfGovernor;
  const DevfreqConfig({required this.dvfGovernor});

  DevfreqConfig copyWith({String? dvfGovernor}) =>
      DevfreqConfig(dvfGovernor: dvfGovernor ?? this.dvfGovernor);
}

// ── UFS config ────────────────────────────────────────────────────────────────

class UfsConfig {
  final String ufsGovernor;

  /// 0 = clock disabled, 1 = clock enabled.
  final int ufsClkEnable;

  const UfsConfig({required this.ufsGovernor, required this.ufsClkEnable});

  UfsConfig copyWith({String? ufsGovernor, int? ufsClkEnable}) {
    return UfsConfig(
      ufsGovernor: ufsGovernor ?? this.ufsGovernor,
      ufsClkEnable: ufsClkEnable ?? this.ufsClkEnable,
    );
  }
}

// ── FPSGO config ──────────────────────────────────────────────────────────────

class FpsgoConfig {
  /// 0 = off, 1 = on, 2 = free (default).
  final int forceOnOff;

  /// 0 = disabled, 1 = enabled.
  final int boostTa;

  const FpsgoConfig({required this.forceOnOff, required this.boostTa});

  FpsgoConfig copyWith({int? forceOnOff, int? boostTa}) {
    return FpsgoConfig(
      forceOnOff: forceOnOff ?? this.forceOnOff,
      boostTa: boostTa ?? this.boostTa,
    );
  }
}

// ── Root profile config ───────────────────────────────────────────────────────

class ProfileConfig {
  final CpuConfig cpu;
  final GpuConfig gpu;
  final DevfreqConfig devfreq;
  final UfsConfig ufs;
  final FpsgoConfig fpsgo;

  const ProfileConfig({
    required this.cpu,
    required this.gpu,
    required this.devfreq,
    required this.ufs,
    required this.fpsgo,
  });

  ProfileConfig copyWith({
    CpuConfig? cpu,
    GpuConfig? gpu,
    DevfreqConfig? devfreq,
    UfsConfig? ufs,
    FpsgoConfig? fpsgo,
  }) {
    return ProfileConfig(
      cpu: cpu ?? this.cpu,
      gpu: gpu ?? this.gpu,
      devfreq: devfreq ?? this.devfreq,
      ufs: ufs ?? this.ufs,
      fpsgo: fpsgo ?? this.fpsgo,
    );
  }
}
