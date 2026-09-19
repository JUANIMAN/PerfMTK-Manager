import 'package:flutter_test/flutter_test.dart';
import 'package:manager/data/parsers/device_conf_parser.dart';

void main() {
  group('DeviceConfParser', () {
    const sampleDeviceConf = '''
# PerfMTK Hardware Configuration
SOC_NAME="Dimensity 8300-Ultra"
ARCH_TYPE="arm64"
GPU_TYPE="gpufreqv2"
TOTAL_POLICIES=3

POLICY_0_PATH="/sys/devices/system/cpu/cpufreq/policy0"
POLICY_0_CPUS="0 1 2 3"
POLICY_0_FREQS="400000 1000000 1500000 2000000"
POLICY_0_GOVERNORS="schedutil sugov_ext performance"
POLICY_0_MAX_FREQ="2000000"
POLICY_0_MIN_FREQ="400000"

POLICY_1_PATH="/sys/devices/system/cpu/cpufreq/policy4"
POLICY_1_CPUS="4 5 6"
POLICY_1_FREQS="600000 1200000 2400000"
POLICY_1_GOVERNORS="schedutil performance"
POLICY_1_MAX_FREQ="2400000"
POLICY_1_MIN_FREQ="600000"

POLICY_2_PATH="/sys/devices/system/cpu/cpufreq/policy7"
POLICY_2_CPUS="7"
POLICY_2_FREQS="800000 1600000 3200000"
POLICY_2_GOVERNORS="schedutil performance"
POLICY_2_MAX_FREQ="3200000"
POLICY_2_MIN_FREQ="800000"

GPU_OPP_TABLE="0:1400000 1:1200000 2:900000 3:500000"
GPU_GOVERNORS="simple_ondemand performance"

DVF_FREQS="1000 2000 3000"
DVF_GOVERNORS="simple_ondemand powersave"
DVF_AVAILABLE="true"

UFS_FREQS="100 200"
UFS_GOVERNORS="simple_ondemand"
UFS_AVAILABLE="true"
''';

    test('parses full device configuration correctly with OPP table', () {
      final config = DeviceConfParser.parse(sampleDeviceConf);

      expect(config.socName, equals('Dimensity 8300-Ultra'));
      expect(config.archType, equals('arm64'));
      expect(config.gpuType, equals('gpufreqv2'));
      expect(config.totalPolicies, equals(3));
      expect(config.policies.length, equals(3));

      // Policy 0
      expect(config.policies[0].cpus, equals([0, 1, 2, 3]));
      expect(config.policies[0].freqs, equals([400000, 1000000, 1500000, 2000000]));
      expect(config.policies[0].governors, equals(['schedutil', 'sugov_ext', 'performance']));
      expect(config.policies[0].maxFreq, equals(2000000));
      expect(config.policies[0].minFreq, equals(400000));

      // GPU OPP Table parsing (KHz sorted descending)
      expect(config.gpuFreqInKHz, isTrue);
      expect(config.gpuFreqs, equals([1400000, 1200000, 900000, 500000]));
      expect(config.gpuGovernors, equals(['simple_ondemand', 'performance']));

      // Devfreq and UFS
      expect(config.dvfAvailable, isTrue);
      expect(config.dvfFreqs, equals([1000, 2000, 3000]));
      expect(config.ufsAvailable, isTrue);
      expect(config.ufsFreqs, equals([100, 200]));
    });

    test('parses legacy GPU_FREQS in Hz and converts to KHz', () {
      const legacyConf = '''
SOC_NAME="Legacy MTK"
TOTAL_POLICIES=0
GPU_FREQS="1400000000 900000000 500000000"
''';
      final config = DeviceConfParser.parse(legacyConf);
      expect(config.gpuFreqInKHz, isFalse);
      expect(config.gpuFreqs, equals([1400000, 900000, 500000]));
    });

    test('generates cumulative CPUs when count format is provided', () {
      const countConf = '''
TOTAL_POLICIES=2
POLICY_0_CPUS="4"
POLICY_1_CPUS="4"
''';
      final config = DeviceConfParser.parse(countConf);
      expect(config.policies[0].cpus, equals([0, 1, 2, 3]));
      expect(config.policies[1].cpus, equals([4, 5, 6, 7]));
    });
  });
}
