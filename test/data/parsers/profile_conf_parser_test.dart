import 'package:flutter_test/flutter_test.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/parsers/profile_conf_parser.dart';

void main() {
  group('ProfileConfParser', () {
    const sampleProfileConf = '''
# BALANCED Profile Configuration
# Balance between performance and battery life

[CPU]
GOVERNOR="schedutil schedutil performance"
DOWN_RATE_LIMIT_US="1000 1000 2000"
UP_RATE_LIMIT_US="500 500 1000"
CORE_CONFIG="cpu0:4:4|cpu4:3:2|cpu7:1:0"
MAX_FREQS="2000000 2400000 3200000"
MIN_FREQS="400000 600000 800000"
SCHED_ENERGY_AWARE=1
LATENCY_SENSITIVE=0

[UCLAMP]
UCLAMP_MIN_TOP_APP=20
UCLAMP_MAX_TOP_APP=100
UCLAMP_MIN_FG=10
UCLAMP_MAX_FG=80

[GPU]
# GPU_FREQ: [265000 - 1400000]=(Fix GPU Frequency), -1=(re-enable GPU DVFS)
GPU_FREQ=900000
GPU_MIN_FREQ=650000
GPU_MAX_FREQ=1400000
GPU_GOVERNOR="simple_ondemand"
GED_DVFS_MARGIN=10
GED_LOADING_STEP=5
GED_BOOST_LEVEL=1
GED_SMART_BOOST=1
GED_BOOST_ENABLE=1

[DEVFREQ]
DVF_GOVERNOR="simple_ondemand"
DVF_MIN_FREQ=1000

[UFS]
UFS_GOVERNOR="simple_ondemand"
UFS_CLK_ENABLE=1

[FPSGO]
FORCE_ONOFF=2
BOOST_TA=1
FBT_BHR_OPP=15
RESCUE_ENABLE=1
ULTRA_RESCUE=1
CPUMASK_HEAVY=240
FILTER_F_KMIN=1
DOWN_THROTTLE=0

[GBE]
GBE_ENABLE=1
GBE_THRM_HDRM=25

[THERMAL_CHARGE]
BYPASS_CHARGE_THROTTLE=true
GENTLE_CHARGE_MA=500
UNLOCK_FPS_THERMAL=true
BATTERY_TEMP_LIMIT=46
BYPASS_MIN_BATT_PCT=25

[DISPLAY]
REFRESH_RATE=120

[TOUCH]
GAME_MODE=true
THP_SMOOTH=true
''';

    test('parses all sections of profile configuration correctly', () {
      final config = ProfileConfParser.parse(sampleProfileConf);

      // CPU
      expect(config.cpu.governors, equals(['schedutil', 'schedutil', 'performance']));
      expect(config.cpu.downRateLimitUs, equals([1000, 1000, 2000]));
      expect(config.cpu.upRateLimitUs, equals([500, 500, 1000]));
      expect(config.cpu.coreConfig.length, equals(3));
      expect(config.cpu.coreConfig[0].cpuId, equals('cpu0'));
      expect(config.cpu.coreConfig[0].totalCores, equals(4));
      expect(config.cpu.coreConfig[0].onlineCores, equals(4));
      expect(config.cpu.maxFreqs, equals([2000000, 2400000, 3200000]));
      expect(config.cpu.minFreqs, equals([400000, 600000, 800000]));
      expect(config.cpu.schedEnergyAware, equals(1));
      expect(config.cpu.latencySensitive, equals(0));

      // UCLAMP
      expect(config.uclamp.uclampMinTopApp, equals(20));
      expect(config.uclamp.uclampMaxTopApp, equals(100));
      expect(config.uclamp.uclampMinFg, equals(10));
      expect(config.uclamp.uclampMaxFg, equals(80));

      // GPU
      expect(config.gpu.gpuFreq, equals(900000));
      expect(config.gpu.gpuMinFreq, equals(650000));
      expect(config.gpu.gpuMaxFreq, equals(1400000));
      expect(config.gpu.gpuGovernor, equals('simple_ondemand'));
      expect(config.gpu.gedDvfsMargin, equals(10));
      expect(config.gpu.gedLoadingStep, equals(5));
      expect(config.gpu.gedBoostLevel, equals(1));
      expect(config.gpu.gedSmartBoost, equals(1));
      expect(config.gpu.gedBoostEnable, equals(1));

      // DEVFREQ & UFS
      expect(config.devfreq.dvfGovernor, equals('simple_ondemand'));
      expect(config.devfreq.dvfMinFreq, equals(1000));
      expect(config.ufs.ufsGovernor, equals('simple_ondemand'));
      expect(config.ufs.ufsClkEnable, equals(1));

      // FPSGO & GBE
      expect(config.fpsgo.forceOnOff, equals(2));
      expect(config.fpsgo.boostTa, equals(1));
      expect(config.fpsgo.fbtBhrOpp, equals(15));
      expect(config.fpsgo.rescueEnable, equals(1));
      expect(config.fpsgo.ultraRescue, equals(1));
      expect(config.fpsgo.cpumaskHeavy, equals(240));
      expect(config.fpsgo.filterFKmin, equals(1));
      expect(config.fpsgo.downThrottle, equals(0));
      expect(config.gbe.gbeEnable, equals(1));
      expect(config.gbe.gbeThrmHdrm, equals(25));

      // THERMAL & DISPLAY
      expect(config.chargeThermal.bypassChargeThrottle, isTrue);
      expect(config.chargeThermal.gentleChargeMa, equals(500));
      expect(config.chargeThermal.unlockFpsThermal, isTrue);
      expect(config.chargeThermal.batteryTempLimit, equals(46));
      expect(config.chargeThermal.bypassMinBattPct, equals(25));
      expect(config.refreshRate, equals(120));

      // TOUCH
      expect(config.touch.gameMode, isTrue);
      expect(config.touch.thpSmooth, isTrue);
    });

    test('round-trip serialization preserves all values', () {
      final config = ProfileConfParser.parse(sampleProfileConf);
      final serialized = ProfileConfParser.serialize(ProfileType.balanced, config);
      final reloaded = ProfileConfParser.parse(serialized);

      expect(reloaded.cpu.governors, equals(config.cpu.governors));
      expect(reloaded.cpu.maxFreqs, equals(config.cpu.maxFreqs));
      expect(reloaded.cpu.minFreqs, equals(config.cpu.minFreqs));
      expect(reloaded.uclamp.uclampMinTopApp, equals(config.uclamp.uclampMinTopApp));
      expect(reloaded.gpu.gpuFreq, equals(config.gpu.gpuFreq));
      expect(reloaded.gpu.gpuMinFreq, equals(config.gpu.gpuMinFreq));
      expect(reloaded.gpu.gpuMaxFreq, equals(config.gpu.gpuMaxFreq));
      expect(reloaded.gpu.gpuGovernor, equals(config.gpu.gpuGovernor));
      expect(reloaded.gpu.gedSmartBoost, equals(config.gpu.gedSmartBoost));
      expect(reloaded.gpu.gedBoostEnable, equals(config.gpu.gedBoostEnable));
      expect(reloaded.fpsgo.forceOnOff, equals(config.fpsgo.forceOnOff));
      expect(reloaded.fpsgo.rescueEnable, equals(config.fpsgo.rescueEnable));
      expect(reloaded.fpsgo.ultraRescue, equals(config.fpsgo.ultraRescue));
      expect(reloaded.fpsgo.cpumaskHeavy, equals(config.fpsgo.cpumaskHeavy));
      expect(reloaded.gbe.gbeThrmHdrm, equals(config.gbe.gbeThrmHdrm));
      expect(reloaded.chargeThermal.batteryTempLimit, equals(config.chargeThermal.batteryTempLimit));
      expect(reloaded.chargeThermal.gentleChargeMa, equals(config.chargeThermal.gentleChargeMa));
      expect(reloaded.refreshRate, equals(config.refreshRate));
      expect(reloaded.touch.gameMode, equals(config.touch.gameMode));
      expect(reloaded.touch.thpSmooth, equals(config.touch.thpSmooth));
    });

    test('handles DVFS sentinel (-1) correctly', () {
      const dvfsConf = '''
[GPU]
GPU_FREQ=-1
GPU_OPP_INDEX=28
''';
      final config = ProfileConfParser.parse(dvfsConf);
      expect(config.gpu.gpuFreq, equals(-1));

      final serialized = ProfileConfParser.serialize(ProfileType.performance, config);
      expect(serialized.contains('GPU_FREQ=-1'), isTrue);
      expect(serialized.contains('GPU_OPP_INDEX'), isFalse);
    });
  });
}
