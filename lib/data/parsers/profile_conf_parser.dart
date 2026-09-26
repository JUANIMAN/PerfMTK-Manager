import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/profile_config.dart';

/// Pure Dart parser and serializer for PerfMTK profile configurations (*.conf).
class ProfileConfParser {
  const ProfileConfParser._();

  /// Parses the raw string contents of a profile configuration file into [ProfileConfig].
  static ProfileConfig parse(
    String content, {
    bool gpuFreqInKHz = true,
    String gpuType = 'gpufreqv2',
  }) {
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

    final cpu = sections.remove('CPU') ?? {};
    final uclamp = sections.remove('UCLAMP') ?? {};
    final gpu = sections.remove('GPU') ?? {};
    final devfreq = sections.remove('DEVFREQ') ?? {};
    final ufs = sections.remove('UFS') ?? {};
    final fpsgo = sections.remove('FPSGO') ?? {};
    final gbe = sections.remove('GBE') ?? {};
    final chargeThermal = sections.remove('THERMAL_CHARGE') ?? {};
    final display = sections.remove('DISPLAY') ?? {};
    final touch = sections.remove('TOUCH') ?? {};
    final guardian = sections.remove('THERMAL_GUARDIAN') ?? sections.remove('GUARDIAN') ?? {};
    final vm = sections.remove('VM') ?? sections.remove('MEMORY') ?? {};

    // CORE_CONFIG: "cpu0:4:4|cpu4:3:2|cpu7:1:0"
    final coreConfigStr = (cpu['CORE_CONFIG'] ?? '').trim();
    final clusters = (coreConfigStr.isEmpty || coreConfigStr == 'auto')
        ? <CoreClusterConfig>[]
        : coreConfigStr
            .split('|')
            .where((s) => s.isNotEmpty && s.trim() != 'auto')
            .map(CoreClusterConfig.fromString)
            .toList();

    final downList = parseIntList(cpu['DOWN_RATE_LIMIT_US']);
    final upList = parseIntList(cpu['UP_RATE_LIMIT_US']);

    final gpuDvfsSentinel = (gpuType == 'gpufreq') ? 0 : -1;
    int rawGpuFreq = int.tryParse(gpu['GPU_FREQ'] ?? '') ?? gpuDvfsSentinel;
    if (rawGpuFreq == gpuDvfsSentinel || rawGpuFreq <= 0) {
      rawGpuFreq = -1;
    } else if (!gpuFreqInKHz) {
      rawGpuFreq = rawGpuFreq ~/ 1000;
    }

    final bypassCharge =
        chargeThermal['BYPASS_CHARGE_THROTTLE']?.toLowerCase() == 'true' ||
        chargeThermal['BYPASS_CHARGE_THROTTLE'] == '1';
    final hwChargeBypass =
        chargeThermal['HARDWARE_CHARGE_BYPASS']?.toLowerCase() == 'true' ||
        chargeThermal['HARDWARE_CHARGE_BYPASS'] == '1';
    final unlockFps =
        chargeThermal['UNLOCK_FPS_THERMAL']?.toLowerCase() == 'true' ||
        chargeThermal['UNLOCK_FPS_THERMAL'] == '1';
    final bypassMinBatt =
        int.tryParse(chargeThermal['BYPASS_MIN_BATT_PCT'] ?? '') ?? 20;

    final schedEnergyAware = int.tryParse(
      cpu['SCHED_ENERGY_AWARE'] ?? cpu['EAS_SCHED_ENERGY_AWARE'] ?? '',
    );
    final latencySensitive = int.tryParse(
      cpu['LATENCY_SENSITIVE'] ?? uclamp['LATENCY_SENSITIVE'] ?? '',
    );
    final refreshRate = int.tryParse(
      display['REFRESH_RATE'] ?? display['FPS'] ?? '',
    ) ?? 0;

    final touchGameMode =
        touch['GAME_MODE']?.toLowerCase() == 'true' ||
        touch['GAME_MODE'] == '1';
    final touchThpSmooth =
        touch['THP_SMOOTH']?.toLowerCase() == 'true' ||
        touch['THP_SMOOTH'] == '1';

    return ProfileConfig(
      cpu: CpuConfig(
        governors: parseStrList(cpu['GOVERNOR']),
        downRateLimitUs: downList.isEmpty ? [1000] : downList,
        upRateLimitUs: upList.isEmpty ? [1000] : upList,
        coreConfig: clusters,
        maxFreqs: parseIntList(cpu['MAX_FREQS']),
        minFreqs: parseIntList(cpu['MIN_FREQS']),
        schedEnergyAware: schedEnergyAware,
        latencySensitive: latencySensitive,
      ),
      uclamp: UclampConfig(
        uclampMinTopApp:
            int.tryParse(uclamp['UCLAMP_MIN_TOP_APP'] ?? '') ?? 0,
        uclampMaxTopApp:
            int.tryParse(uclamp['UCLAMP_MAX_TOP_APP'] ?? '') ?? 100,
        uclampMinFg: int.tryParse(uclamp['UCLAMP_MIN_FG'] ?? '') ?? 0,
        uclampMaxFg: int.tryParse(uclamp['UCLAMP_MAX_FG'] ?? '') ?? 100,
      ),
      gpu: GpuConfig(
        gpuFreq: rawGpuFreq,
        gpuGovernor: gpu['GPU_GOVERNOR'] ?? 'userspace',
        gedDvfsMargin: int.tryParse(gpu['GED_DVFS_MARGIN'] ?? '') ?? -1,
        gedLoadingStep: int.tryParse(gpu['GED_LOADING_STEP'] ?? '') ?? -1,
        gedBoostLevel: int.tryParse(gpu['GED_BOOST_LEVEL'] ?? '') ?? -1,
        gpuMinFreq: int.tryParse(gpu['GPU_MIN_FREQ'] ?? ''),
        gpuMaxFreq: int.tryParse(gpu['GPU_MAX_FREQ'] ?? ''),
        gedSmartBoost: int.tryParse(gpu['GED_SMART_BOOST'] ?? '') ?? -1,
        gedBoostEnable: int.tryParse(gpu['GED_BOOST_ENABLE'] ?? '') ?? -1,
      ),
      devfreq: DevfreqConfig(
        dvfGovernor: devfreq['DVF_GOVERNOR'] ?? 'userspace',
        dvfMinFreq: int.tryParse(devfreq['DVF_MIN_FREQ'] ?? '') ?? 0,
      ),
      ufs: UfsConfig(
        ufsGovernor: ufs['UFS_GOVERNOR'] ?? 'simple_ondemand',
        ufsClkEnable: int.tryParse(ufs['UFS_CLK_ENABLE'] ?? '') ?? 1,
      ),
      fpsgo: FpsgoConfig(
        forceOnOff: int.tryParse(fpsgo['FORCE_ONOFF'] ?? '') ?? 2,
        boostTa: int.tryParse(fpsgo['BOOST_TA'] ?? '') ?? 0,
        fbtBhrOpp: int.tryParse(fpsgo['FBT_BHR_OPP'] ?? '') ?? 0,
        rescueEnable: int.tryParse(fpsgo['RESCUE_ENABLE'] ?? '') ?? 0,
        ultraRescue: int.tryParse(fpsgo['ULTRA_RESCUE'] ?? '') ?? 0,
        cpumaskHeavy: int.tryParse(fpsgo['CPUMASK_HEAVY'] ?? '') ?? 255,
        filterFKmin: int.tryParse(fpsgo['FILTER_F_KMIN'] ?? '') ?? 0,
        floorBound: int.tryParse(fpsgo['FLOOR_BOUND'] ?? '') ?? 0,
        downThrottle: int.tryParse(fpsgo['DOWN_THROTTLE'] ?? '') ?? 0,
        rescuePercent: int.tryParse(fpsgo['RESCUE_PERCENT'] ?? '') ?? 0,
        rescueEnhanceF: int.tryParse(fpsgo['RESCUE_ENHANCE_F'] ?? '') ?? 0,
      ),
      gbe: GbeConfig(
        gbeEnable: int.tryParse(gbe['GBE_ENABLE'] ?? '') ?? 1,
        gbeThrmHdrm: int.tryParse(gbe['GBE_THRM_HDRM'] ?? '') ?? 20,
        magtCurrentAvg: int.tryParse(gbe['MAGT_CURRENT_AVG'] ?? '') ?? 0,
        magtCurrentMax: int.tryParse(gbe['MAGT_CURRENT_MAX'] ?? '') ?? 0,
        magtFpsdropThrs: int.tryParse(gbe['MAGT_FPSDROP_THRS'] ?? '') ?? 0,
      ),
      chargeThermal: ChargeThermalConfig(
        bypassChargeThrottle: bypassCharge,
        hardwareChargeBypass: hwChargeBypass,
        unlockFpsThermal: unlockFps,
        batteryTempLimit:
            int.tryParse(chargeThermal['BATTERY_TEMP_LIMIT'] ?? '') ?? 48,
        bypassMinBattPct: bypassMinBatt,
        gentleChargeMa:
            int.tryParse(chargeThermal['GENTLE_CHARGE_MA'] ?? '') ?? 0,
        maxChargeMa:
            int.tryParse(chargeThermal['MAX_CHARGE_MA'] ?? '') ?? 0,
        batteryCareEnabled:
            chargeThermal['BATTERY_CARE_ENABLED']?.toLowerCase() == 'true' ||
            chargeThermal['BATTERY_CARE_ENABLED'] == '1',
        batteryCareLimit:
            int.tryParse(chargeThermal['BATTERY_CARE_LIMIT'] ?? '') ?? 80,
        disableThermalServices:
            chargeThermal['DISABLE_THERMAL_SERVICES']?.toLowerCase() == 'true' ||
            chargeThermal['DISABLE_THERMAL_SERVICES'] == '1',
      ),
      refreshRate: refreshRate,
      touch: TouchConfig(
        gameMode: touchGameMode,
        thpSmooth: touchThpSmooth,
        touchDownThreshold: int.tryParse(
          touch['TOUCH_DOWN_THRESHOLD'] ?? touch['TOUCH_DOWNTHD'] ?? '',
        ) ?? 0,
        touchMoveThreshold: int.tryParse(
          touch['TOUCH_MOVE_THRESHOLD'] ?? touch['TOUCH_MOVETHD'] ?? '',
        ) ?? 0,
      ),
      vm: VmConfig(
        swappiness: int.tryParse(vm['SWAPPINESS'] ?? '') ?? 100,
        statInterval: int.tryParse(vm['STAT_INTERVAL'] ?? '') ?? 5,
        watermarkScaleFactor: int.tryParse(
          vm['WATERMARK_SCALE_FACTOR'] ?? vm['WMARK_SCALE'] ?? '',
        ) ?? 100,
        mglru: vm.containsKey('MGLRU')
            ? (vm['MGLRU']?.toLowerCase() == 'true' || vm['MGLRU'] == '1')
            : (vm['MGLRU_ENABLED']?.toLowerCase() == 'true' ||
                vm['MGLRU_ENABLED'] == '1' ||
                true),
        mglruMinTtlMs: int.tryParse(vm['MGLRU_MIN_TTL_MS'] ?? '') ?? 0,
        compactionProactiveness:
            int.tryParse(vm['COMPACTION_PROACTIVENESS'] ?? '') ?? 0,
        schedSchedstats: int.tryParse(vm['SCHED_SCHEDSTATS'] ?? '') ?? 0,
        compactOnLaunch:
            vm['COMPACT_ON_LAUNCH']?.toLowerCase() == 'true' ||
            vm['COMPACT_ON_LAUNCH'] == '1',
      ),
      thermalGuardian: ThermalGuardianConfig(
        enable: guardian['ENABLE']?.toLowerCase() == 'true' ||
            guardian['ENABLED']?.toLowerCase() == 'true' ||
            guardian['ENABLE'] == '1',
        tempTarget: int.tryParse(
          guardian['TEMP_TARGET'] ?? guardian['TARGET_TEMP'] ?? '',
        ) ?? 45,
        stepDownMax: int.tryParse(
          guardian['STEP_DOWN_MAX'] ?? guardian['MAX_STEPS'] ?? '',
        ) ?? 3,
        uclampStepPct: int.tryParse(guardian['UCLAMP_STEP_PCT'] ?? '') ?? 10,
      ),
      extraSections: sections,
    );
  }

  /// Serializes a [ProfileConfig] to standard PerfMTK INI format.
  static String serialize(
    ProfileType profile,
    ProfileConfig c, {
    bool gpuFreqInKHz = true,
    String gpuType = 'gpufreqv2',
  }) {
    final title = profileTitle(profile);
    final desc = profileDesc(profile);
    final gpuDvfsSentinel = (gpuType == 'gpufreq') ? 0 : -1;

    final gpuFreqStr = c.gpu.gpuFreq == -1
        ? gpuDvfsSentinel.toString()
        : (gpuFreqInKHz
              ? c.gpu.gpuFreq.toString()
              : (c.gpu.gpuFreq * 1000).toString());

    final gpuGovernorStr = (gpuType == 'gpufreq')
        ? 'none'
        : c.gpu.gpuGovernor;

    final gpuComment = gpuFreqInKHz
        ? '# GPU_FREQ: [265000 - 1400000]=(Fix GPU Frequency), $gpuDvfsSentinel=(re-enable GPU DVFS)'
        : '# GPU_FREQ: [265000000 - 1400000000]=(Fix GPU Frequency), $gpuDvfsSentinel=(re-enable GPU DVFS)';

    final coreStr = c.cpu.coreConfigString.isEmpty ? 'auto' : c.cpu.coreConfigString;
    final maxStr = c.cpu.maxFreqString.isEmpty ? 'auto' : c.cpu.maxFreqString;
    final minStr = c.cpu.minFreqString.isEmpty ? 'auto' : c.cpu.minFreqString;

    final b = StringBuffer()
      ..writeln('# $title Profile Configuration')
      ..writeln('# $desc')
      ..writeln()
      ..writeln('[CPU]')
      ..writeln(
        '# GOVERNOR accepts one value for all policies or one value per CPU policy.',
      )
      ..writeln('GOVERNOR="${c.cpu.governorString}"')
      ..writeln(
        '# *_RATE_LIMIT_US accepts one value for all policies or one value per CPU policy.',
      )
      ..writeln('DOWN_RATE_LIMIT_US="${c.cpu.downRateLimitString}"')
      ..writeln('UP_RATE_LIMIT_US="${c.cpu.upRateLimitString}"')
      ..writeln('CORE_CONFIG="$coreStr"')
      ..writeln('MAX_FREQS="$maxStr"')
      ..writeln('MIN_FREQS="$minStr"');

    if (c.cpu.schedEnergyAware != null) {
      b.writeln('SCHED_ENERGY_AWARE=${c.cpu.schedEnergyAware}');
    }
    if (c.cpu.latencySensitive != null) {
      b.writeln('LATENCY_SENSITIVE=${c.cpu.latencySensitive}');
    }

    b
      ..writeln()
      ..writeln('[UCLAMP]')
      ..writeln('UCLAMP_MIN_TOP_APP=${c.uclamp.uclampMinTopApp}')
      ..writeln('UCLAMP_MAX_TOP_APP=${c.uclamp.uclampMaxTopApp}')
      ..writeln('UCLAMP_MIN_FG=${c.uclamp.uclampMinFg}')
      ..writeln('UCLAMP_MAX_FG=${c.uclamp.uclampMaxFg}');

    if (c.cpu.latencySensitive != null) {
      b.writeln('LATENCY_SENSITIVE=${c.cpu.latencySensitive}');
    }

    b
      ..writeln()
      ..writeln('[GPU]')
      ..writeln(gpuComment)
      ..writeln('GPU_FREQ=$gpuFreqStr');

    if (gpuType != 'gpufreq' && c.gpu.gpuMinFreq != null && c.gpu.gpuMinFreq! > 0) {
      b.writeln('GPU_MIN_FREQ=${c.gpu.gpuMinFreq}');
    }
    if (gpuType != 'gpufreq' && c.gpu.gpuMaxFreq != null && c.gpu.gpuMaxFreq! > 0) {
      b.writeln('GPU_MAX_FREQ=${c.gpu.gpuMaxFreq}');
    }

    b.writeln('GPU_GOVERNOR="$gpuGovernorStr"');

    if (c.gpu.gedDvfsMargin >= 0) {
      b.writeln('GED_DVFS_MARGIN=${c.gpu.gedDvfsMargin}');
    }
    if (c.gpu.gedLoadingStep >= 0) {
      b.writeln('GED_LOADING_STEP=${c.gpu.gedLoadingStep}');
    }
    if (c.gpu.gedBoostLevel >= 0) {
      b.writeln('GED_BOOST_LEVEL=${c.gpu.gedBoostLevel}');
    }
    if (c.gpu.gedSmartBoost >= 0) {
      b.writeln('GED_SMART_BOOST=${c.gpu.gedSmartBoost}');
    }
    if (c.gpu.gedBoostEnable >= 0) {
      b.writeln('GED_BOOST_ENABLE=${c.gpu.gedBoostEnable}');
    }

    b
      ..writeln()
      ..writeln('[DEVFREQ]')
      ..writeln('DVF_GOVERNOR="${c.devfreq.dvfGovernor}"');

    if (c.devfreq.dvfMinFreq > 0) {
      b.writeln('DVF_MIN_FREQ=${c.devfreq.dvfMinFreq}');
    }

    b
      ..writeln()
      ..writeln('[UFS]')
      ..writeln('UFS_GOVERNOR="${c.ufs.ufsGovernor}"')
      ..writeln('UFS_CLK_ENABLE=${c.ufs.ufsClkEnable}')
      ..writeln()
      ..writeln('[FPSGO]')
      ..writeln('# FORCE_ONOFF: 0=off, 1=on, 2=free(default)')
      ..writeln('FORCE_ONOFF=${c.fpsgo.forceOnOff}')
      ..writeln('BOOST_TA=${c.fpsgo.boostTa}');

    if (c.fpsgo.fbtBhrOpp > 0) {
      b.writeln('FBT_BHR_OPP=${c.fpsgo.fbtBhrOpp}');
    }
    if (c.fpsgo.rescueEnable > 0) {
      b.writeln('RESCUE_ENABLE=${c.fpsgo.rescueEnable}');
    }
    if (c.fpsgo.ultraRescue > 0) {
      b.writeln('ULTRA_RESCUE=${c.fpsgo.ultraRescue}');
    }
    if (c.fpsgo.cpumaskHeavy != 255) {
      b.writeln('CPUMASK_HEAVY=${c.fpsgo.cpumaskHeavy}');
    }
    if (c.fpsgo.filterFKmin > 0) {
      b.writeln('FILTER_F_KMIN=${c.fpsgo.filterFKmin}');
    }
    if (c.fpsgo.floorBound > 0) {
      b.writeln('FLOOR_BOUND=${c.fpsgo.floorBound}');
    }
    if (c.fpsgo.downThrottle != 0) {
      b.writeln('DOWN_THROTTLE=${c.fpsgo.downThrottle}');
    }
    if (c.fpsgo.rescuePercent > 0) {
      b.writeln('RESCUE_PERCENT=${c.fpsgo.rescuePercent}');
    }
    if (c.fpsgo.rescueEnhanceF > 0) {
      b.writeln('RESCUE_ENHANCE_F=${c.fpsgo.rescueEnhanceF}');
    }

    b
      ..writeln()
      ..writeln('[GBE]')
      ..writeln('GBE_ENABLE=${c.gbe.gbeEnable}')
      ..writeln('GBE_THRM_HDRM=${c.gbe.gbeThrmHdrm}');

    if (c.gbe.magtCurrentAvg > 0) {
      b.writeln('MAGT_CURRENT_AVG=${c.gbe.magtCurrentAvg}');
    }
    if (c.gbe.magtCurrentMax > 0) {
      b.writeln('MAGT_CURRENT_MAX=${c.gbe.magtCurrentMax}');
    }
    if (c.gbe.magtFpsdropThrs > 0 || c.gbe.magtCurrentAvg > 0) {
      b.writeln('MAGT_FPSDROP_THRS=${c.gbe.magtFpsdropThrs}');
    }

    b
      ..writeln()
      ..writeln('[THERMAL_CHARGE]')
      ..writeln('BYPASS_CHARGE_THROTTLE=${c.chargeThermal.bypassChargeThrottle}')
      ..writeln('HARDWARE_CHARGE_BYPASS=${c.chargeThermal.hardwareChargeBypass}');

    if (c.chargeThermal.gentleChargeMa > 0) {
      b.writeln('GENTLE_CHARGE_MA=${c.chargeThermal.gentleChargeMa}');
    }
    if (c.chargeThermal.maxChargeMa > 0) {
      b.writeln('MAX_CHARGE_MA=${c.chargeThermal.maxChargeMa}');
    }

    b
      ..writeln('UNLOCK_FPS_THERMAL=${c.chargeThermal.unlockFpsThermal}')
      ..writeln('BATTERY_TEMP_LIMIT=${c.chargeThermal.batteryTempLimit}')
      ..writeln('BYPASS_MIN_BATT_PCT=${c.chargeThermal.bypassMinBattPct}');

    if (c.chargeThermal.batteryCareEnabled) {
      b.writeln('BATTERY_CARE_ENABLED=${c.chargeThermal.batteryCareEnabled}');
      b.writeln('BATTERY_CARE_LIMIT=${c.chargeThermal.batteryCareLimit}');
    }
    if (c.chargeThermal.disableThermalServices) {
      b.writeln('DISABLE_THERMAL_SERVICES=${c.chargeThermal.disableThermalServices}');
    }

    b
      ..writeln()
      ..writeln('[DISPLAY]')
      ..writeln('REFRESH_RATE=${c.refreshRate}');

    if (c.thermalGuardian.enable) {
      b
        ..writeln()
        ..writeln('[THERMAL_GUARDIAN]')
        ..writeln('ENABLE=${c.thermalGuardian.enable}')
        ..writeln('TEMP_TARGET=${c.thermalGuardian.tempTarget}')
        ..writeln('STEP_DOWN_MAX=${c.thermalGuardian.stepDownMax}')
        ..writeln('UCLAMP_STEP_PCT=${c.thermalGuardian.uclampStepPct}');
    }

    b
      ..writeln()
      ..writeln('[VM]')
      ..writeln('SWAPPINESS=${c.vm.swappiness}')
      ..writeln('STAT_INTERVAL=${c.vm.statInterval}')
      ..writeln('WATERMARK_SCALE_FACTOR=${c.vm.watermarkScaleFactor}')
      ..writeln('MGLRU=${c.vm.mglru}');

    if (c.vm.mglruMinTtlMs > 0) {
      b.writeln('MGLRU_MIN_TTL_MS=${c.vm.mglruMinTtlMs}');
    }
    if (c.vm.compactionProactiveness > 0) {
      b.writeln('COMPACTION_PROACTIVENESS=${c.vm.compactionProactiveness}');
    }
    if (c.vm.schedSchedstats > 0) {
      b.writeln('SCHED_SCHEDSTATS=${c.vm.schedSchedstats}');
    }
    if (c.vm.compactOnLaunch) {
      b.writeln('COMPACT_ON_LAUNCH=${c.vm.compactOnLaunch}');
    }

    b
      ..writeln()
      ..writeln('[TOUCH]')
      ..writeln('GAME_MODE=${c.touch.gameMode}')
      ..writeln('THP_SMOOTH=${c.touch.thpSmooth}')
      ..writeln('TOUCH_DOWN_THRESHOLD=${c.touch.touchDownThreshold}')
      ..writeln('TOUCH_MOVE_THRESHOLD=${c.touch.touchMoveThreshold}');

    for (final entry in c.extraSections.entries) {
      b
        ..writeln()
        ..writeln('[${entry.key}]');
      for (final kv in entry.value.entries) {
        b.writeln('${kv.key}=${kv.value}');
      }
    }

    return b.toString();
  }

  static String profileTitle(ProfileType p) {
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

  static String profileDesc(ProfileType p) {
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

  static List<int> parseIntList(String? s) {
    if (s == null || s.isEmpty || s.trim() == 'auto') return [];
    return s
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty && e.trim() != 'auto')
        .map((e) => int.tryParse(e) ?? 0)
        .where((e) => e > 0)
        .toList();
  }

  static List<String> parseStrList(String? s) {
    if (s == null || s.isEmpty) return [];
    return s.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  }
}
