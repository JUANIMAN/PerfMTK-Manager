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

  /// Kernel EAS scheduler energy awareness (0=pure performance, 1=energy aware).
  final int? schedEnergyAware;

  /// Top-app latency sensitivity for zero-latency frequency ramp-up.
  final int? latencySensitive;

  const CpuConfig({
    required this.governors,
    required this.downRateLimitUs,
    required this.upRateLimitUs,
    required this.coreConfig,
    required this.maxFreqs,
    required this.minFreqs,
    this.schedEnergyAware,
    this.latencySensitive,
  });

  CpuConfig copyWith({
    List<String>? governors,
    List<int>? downRateLimitUs,
    List<int>? upRateLimitUs,
    List<CoreClusterConfig>? coreConfig,
    List<int>? maxFreqs,
    List<int>? minFreqs,
    int? schedEnergyAware,
    int? latencySensitive,
  }) {
    return CpuConfig(
      governors: governors ?? this.governors,
      downRateLimitUs: downRateLimitUs ?? this.downRateLimitUs,
      upRateLimitUs: upRateLimitUs ?? this.upRateLimitUs,
      coreConfig: coreConfig ?? this.coreConfig,
      maxFreqs: maxFreqs ?? this.maxFreqs,
      minFreqs: minFreqs ?? this.minFreqs,
      schedEnergyAware: schedEnergyAware ?? this.schedEnergyAware,
      latencySensitive: latencySensitive ?? this.latencySensitive,
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

// ── UCLAMP config ─────────────────────────────────────────────────────────────

class UclampConfig {
  final int uclampMinTopApp;
  final int uclampMaxTopApp;
  final int uclampMinFg;
  final int uclampMaxFg;

  const UclampConfig({
    this.uclampMinTopApp = 0,
    this.uclampMaxTopApp = 100,
    this.uclampMinFg = 0,
    this.uclampMaxFg = 100,
  });

  UclampConfig copyWith({
    int? uclampMinTopApp,
    int? uclampMaxTopApp,
    int? uclampMinFg,
    int? uclampMaxFg,
  }) {
    return UclampConfig(
      uclampMinTopApp: uclampMinTopApp ?? this.uclampMinTopApp,
      uclampMaxTopApp: uclampMaxTopApp ?? this.uclampMaxTopApp,
      uclampMinFg: uclampMinFg ?? this.uclampMinFg,
      uclampMaxFg: uclampMaxFg ?? this.uclampMaxFg,
    );
  }
}

// ── GPU config ────────────────────────────────────────────────────────────────

class GpuConfig {
  /// Fixed GPU frequency in Hz, or -1 to let the driver choose (DVFS enabled).
  final int gpuFreq;
  final String gpuGovernor;
  final int gedDvfsMargin;
  final int gedLoadingStep;
  final int gedBoostLevel;

  /// Dynamic GPU DVFS bottom floor in KHz (e.g. 650000 for 650MHz).
  final int? gpuMinFreq;

  /// Dynamic GPU DVFS ceiling in KHz (e.g. 1400000 for 1400MHz).
  final int? gpuMaxFreq;

  /// MediaTek GED Smart Boost policy (0=disabled, 1=enabled).
  final int gedSmartBoost;

  /// MediaTek GED Boost Enable (0=disabled, 1=enabled).
  final int gedBoostEnable;

  const GpuConfig({
    required this.gpuFreq,
    required this.gpuGovernor,
    this.gedDvfsMargin = -1,
    this.gedLoadingStep = -1,
    this.gedBoostLevel = -1,
    this.gpuMinFreq,
    this.gpuMaxFreq,
    this.gedSmartBoost = -1,
    this.gedBoostEnable = -1,
  });

  bool get isDvfsEnabled => gpuFreq == -1;

  GpuConfig copyWith({
    int? gpuFreq,
    String? gpuGovernor,
    int? gedDvfsMargin,
    int? gedLoadingStep,
    int? gedBoostLevel,
    int? gpuMinFreq,
    int? gpuMaxFreq,
    int? gedSmartBoost,
    int? gedBoostEnable,
  }) {
    return GpuConfig(
      gpuFreq: gpuFreq ?? this.gpuFreq,
      gpuGovernor: gpuGovernor ?? this.gpuGovernor,
      gedDvfsMargin: gedDvfsMargin ?? this.gedDvfsMargin,
      gedLoadingStep: gedLoadingStep ?? this.gedLoadingStep,
      gedBoostLevel: gedBoostLevel ?? this.gedBoostLevel,
      gpuMinFreq: gpuMinFreq ?? this.gpuMinFreq,
      gpuMaxFreq: gpuMaxFreq ?? this.gpuMaxFreq,
      gedSmartBoost: gedSmartBoost ?? this.gedSmartBoost,
      gedBoostEnable: gedBoostEnable ?? this.gedBoostEnable,
    );
  }
}

// ── DEVFREQ config ────────────────────────────────────────────────────────────

class DevfreqConfig {
  final String dvfGovernor;
  final int dvfMinFreq;

  const DevfreqConfig({
    required this.dvfGovernor,
    this.dvfMinFreq = 0,
  });

  DevfreqConfig copyWith({String? dvfGovernor, int? dvfMinFreq}) =>
      DevfreqConfig(
        dvfGovernor: dvfGovernor ?? this.dvfGovernor,
        dvfMinFreq: dvfMinFreq ?? this.dvfMinFreq,
      );
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

  final int fbtBhrOpp;

  /// Frame drop rescue mechanism (0=disabled, 1=enabled).
  final int rescueEnable;

  /// Ultra aggressive rescue for heavy frame drops (0=disabled, 1=enabled).
  final int ultraRescue;

  /// CPU mask for heavy frame rescue (e.g. 240 = 0xF0 Big/Prime cores, 255 = all).
  final int cpumaskHeavy;

  /// MediaTek FBT filter minimum factor.
  final int filterFKmin;

  /// Floor bound frequency index.
  final int floorBound;

  /// Aggressive down-throttling clamp suppression (0=unthrottled, 1=throttled).
  final int downThrottle;

  /// Rescue target percentage boost.
  final int rescuePercent;

  /// Rescue enhance factor.
  final int rescueEnhanceF;

  const FpsgoConfig({
    required this.forceOnOff,
    required this.boostTa,
    this.fbtBhrOpp = 0,
    this.rescueEnable = 0,
    this.ultraRescue = 0,
    this.cpumaskHeavy = 255,
    this.filterFKmin = 0,
    this.floorBound = 0,
    this.downThrottle = 0,
    this.rescuePercent = 0,
    this.rescueEnhanceF = 0,
  });

  FpsgoConfig copyWith({
    int? forceOnOff,
    int? boostTa,
    int? fbtBhrOpp,
    int? rescueEnable,
    int? ultraRescue,
    int? cpumaskHeavy,
    int? filterFKmin,
    int? floorBound,
    int? downThrottle,
    int? rescuePercent,
    int? rescueEnhanceF,
  }) {
    return FpsgoConfig(
      forceOnOff: forceOnOff ?? this.forceOnOff,
      boostTa: boostTa ?? this.boostTa,
      fbtBhrOpp: fbtBhrOpp ?? this.fbtBhrOpp,
      rescueEnable: rescueEnable ?? this.rescueEnable,
      ultraRescue: ultraRescue ?? this.ultraRescue,
      cpumaskHeavy: cpumaskHeavy ?? this.cpumaskHeavy,
      filterFKmin: filterFKmin ?? this.filterFKmin,
      floorBound: floorBound ?? this.floorBound,
      downThrottle: downThrottle ?? this.downThrottle,
      rescuePercent: rescuePercent ?? this.rescuePercent,
      rescueEnhanceF: rescueEnhanceF ?? this.rescueEnhanceF,
    );
  }
}

// ── GBE (Game Turbo / MAGT) config ──────────────────────────────────────────

class GbeConfig {
  final int gbeEnable;
  final int gbeThrmHdrm;
  final int magtCurrentAvg;
  final int magtCurrentMax;
  final int magtFpsdropThrs;

  const GbeConfig({
    this.gbeEnable = 1,
    this.gbeThrmHdrm = 20,
    this.magtCurrentAvg = 0,
    this.magtCurrentMax = 0,
    this.magtFpsdropThrs = 0,
  });

  GbeConfig copyWith({
    int? gbeEnable,
    int? gbeThrmHdrm,
    int? magtCurrentAvg,
    int? magtCurrentMax,
    int? magtFpsdropThrs,
  }) {
    return GbeConfig(
      gbeEnable: gbeEnable ?? this.gbeEnable,
      gbeThrmHdrm: gbeThrmHdrm ?? this.gbeThrmHdrm,
      magtCurrentAvg: magtCurrentAvg ?? this.magtCurrentAvg,
      magtCurrentMax: magtCurrentMax ?? this.magtCurrentMax,
      magtFpsdropThrs: magtFpsdropThrs ?? this.magtFpsdropThrs,
    );
  }
}

// ── THERMAL & CHARGE config ───────────────────────────────────────────────────

class ChargeThermalConfig {
  final bool bypassChargeThrottle;
  final bool hardwareChargeBypass;
  final bool unlockFpsThermal;
  final int batteryTempLimit;
  final int bypassMinBattPct;

  /// Gentle charging current in mA (e.g. 500 = 500mA gentle charging, 0 = unrestricted).
  final int gentleChargeMa;

  /// Maximum charging current ceiling in mA (0 = unrestricted).
  final int maxChargeMa;

  /// Battery care cut-off toggle.
  final bool batteryCareEnabled;

  /// Battery care charge limit percentage (e.g. 80).
  final int batteryCareLimit;

  /// Temporarily disable OEM thermal throttling services for sustained performance.
  final bool disableThermalServices;

  const ChargeThermalConfig({
    this.bypassChargeThrottle = false,
    this.hardwareChargeBypass = false,
    this.unlockFpsThermal = false,
    this.batteryTempLimit = 48,
    this.bypassMinBattPct = 20,
    this.gentleChargeMa = 0,
    this.maxChargeMa = 0,
    this.batteryCareEnabled = false,
    this.batteryCareLimit = 80,
    this.disableThermalServices = false,
  });

  ChargeThermalConfig copyWith({
    bool? bypassChargeThrottle,
    bool? hardwareChargeBypass,
    bool? unlockFpsThermal,
    int? batteryTempLimit,
    int? bypassMinBattPct,
    int? gentleChargeMa,
    int? maxChargeMa,
    bool? batteryCareEnabled,
    int? batteryCareLimit,
    bool? disableThermalServices,
  }) {
    return ChargeThermalConfig(
      bypassChargeThrottle: bypassChargeThrottle ?? this.bypassChargeThrottle,
      hardwareChargeBypass: hardwareChargeBypass ?? this.hardwareChargeBypass,
      unlockFpsThermal: unlockFpsThermal ?? this.unlockFpsThermal,
      batteryTempLimit: batteryTempLimit ?? this.batteryTempLimit,
      bypassMinBattPct: bypassMinBattPct ?? this.bypassMinBattPct,
      gentleChargeMa: gentleChargeMa ?? this.gentleChargeMa,
      maxChargeMa: maxChargeMa ?? this.maxChargeMa,
      batteryCareEnabled: batteryCareEnabled ?? this.batteryCareEnabled,
      batteryCareLimit: batteryCareLimit ?? this.batteryCareLimit,
      disableThermalServices:
          disableThermalServices ?? this.disableThermalServices,
    );
  }
}

// ── TOUCH (Digitizer Booster) config ──────────────────────────────────────────

class TouchConfig {
  final bool gameMode;
  final bool thpSmooth;
  final int touchDownThreshold;
  final int touchMoveThreshold;

  const TouchConfig({
    this.gameMode = false,
    this.thpSmooth = false,
    this.touchDownThreshold = 0,
    this.touchMoveThreshold = 0,
  });

  TouchConfig copyWith({
    bool? gameMode,
    bool? thpSmooth,
    int? touchDownThreshold,
    int? touchMoveThreshold,
  }) {
    return TouchConfig(
      gameMode: gameMode ?? this.gameMode,
      thpSmooth: thpSmooth ?? this.thpSmooth,
      touchDownThreshold: touchDownThreshold ?? this.touchDownThreshold,
      touchMoveThreshold: touchMoveThreshold ?? this.touchMoveThreshold,
    );
  }
}

// ── VM (Virtual Memory / ZRAM / MGLRU) config ────────────────────────────────

class VmConfig {
  final int swappiness;
  final int statInterval;
  final int watermarkScaleFactor;
  final bool mglru;
  final int mglruMinTtlMs;
  final int compactionProactiveness;
  final int schedSchedstats;
  final bool compactOnLaunch;

  const VmConfig({
    this.swappiness = 100,
    this.statInterval = 5,
    this.watermarkScaleFactor = 100,
    this.mglru = true,
    this.mglruMinTtlMs = 0,
    this.compactionProactiveness = 0,
    this.schedSchedstats = 0,
    this.compactOnLaunch = false,
  });

  VmConfig copyWith({
    int? swappiness,
    int? statInterval,
    int? watermarkScaleFactor,
    bool? mglru,
    int? mglruMinTtlMs,
    int? compactionProactiveness,
    int? schedSchedstats,
    bool? compactOnLaunch,
  }) {
    return VmConfig(
      swappiness: swappiness ?? this.swappiness,
      statInterval: statInterval ?? this.statInterval,
      watermarkScaleFactor: watermarkScaleFactor ?? this.watermarkScaleFactor,
      mglru: mglru ?? this.mglru,
      mglruMinTtlMs: mglruMinTtlMs ?? this.mglruMinTtlMs,
      compactionProactiveness:
          compactionProactiveness ?? this.compactionProactiveness,
      schedSchedstats: schedSchedstats ?? this.schedSchedstats,
      compactOnLaunch: compactOnLaunch ?? this.compactOnLaunch,
    );
  }
}

// ── THERMAL GUARDIAN config ──────────────────────────────────────────────────

class ThermalGuardianConfig {
  final bool enable;
  final int tempTarget;
  final int stepDownMax;
  final int uclampStepPct;

  const ThermalGuardianConfig({
    this.enable = false,
    this.tempTarget = 45,
    this.stepDownMax = 3,
    this.uclampStepPct = 10,
  });

  ThermalGuardianConfig copyWith({
    bool? enable,
    int? tempTarget,
    int? stepDownMax,
    int? uclampStepPct,
  }) {
    return ThermalGuardianConfig(
      enable: enable ?? this.enable,
      tempTarget: tempTarget ?? this.tempTarget,
      stepDownMax: stepDownMax ?? this.stepDownMax,
      uclampStepPct: uclampStepPct ?? this.uclampStepPct,
    );
  }
}

// ── Root profile config ───────────────────────────────────────────────────────

class ProfileConfig {
  final CpuConfig cpu;
  final UclampConfig uclamp;
  final GpuConfig gpu;
  final DevfreqConfig devfreq;
  final UfsConfig ufs;
  final FpsgoConfig fpsgo;
  final GbeConfig gbe;
  final ChargeThermalConfig chargeThermal;
  final int refreshRate;
  final TouchConfig touch;
  final VmConfig vm;
  final ThermalGuardianConfig thermalGuardian;
  final Map<String, Map<String, String>> extraSections;

  const ProfileConfig({
    required this.cpu,
    this.uclamp = const UclampConfig(),
    required this.gpu,
    required this.devfreq,
    required this.ufs,
    required this.fpsgo,
    this.gbe = const GbeConfig(),
    this.chargeThermal = const ChargeThermalConfig(),
    this.refreshRate = 0,
    this.touch = const TouchConfig(),
    this.vm = const VmConfig(),
    this.thermalGuardian = const ThermalGuardianConfig(),
    this.extraSections = const {},
  });

  ProfileConfig copyWith({
    CpuConfig? cpu,
    UclampConfig? uclamp,
    GpuConfig? gpu,
    DevfreqConfig? devfreq,
    UfsConfig? ufs,
    FpsgoConfig? fpsgo,
    GbeConfig? gbe,
    ChargeThermalConfig? chargeThermal,
    int? refreshRate,
    TouchConfig? touch,
    VmConfig? vm,
    ThermalGuardianConfig? thermalGuardian,
    Map<String, Map<String, String>>? extraSections,
  }) {
    return ProfileConfig(
      cpu: cpu ?? this.cpu,
      uclamp: uclamp ?? this.uclamp,
      gpu: gpu ?? this.gpu,
      devfreq: devfreq ?? this.devfreq,
      ufs: ufs ?? this.ufs,
      fpsgo: fpsgo ?? this.fpsgo,
      gbe: gbe ?? this.gbe,
      chargeThermal: chargeThermal ?? this.chargeThermal,
      refreshRate: refreshRate ?? this.refreshRate,
      touch: touch ?? this.touch,
      vm: vm ?? this.vm,
      thermalGuardian: thermalGuardian ?? this.thermalGuardian,
      extraSections: extraSections ?? this.extraSections,
    );
  }
}
