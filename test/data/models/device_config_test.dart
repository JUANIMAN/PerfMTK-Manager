import 'package:flutter_test/flutter_test.dart';
import 'package:manager/data/models/device_config.dart';

void main() {
  group('DeviceConfig.fromJson', () {
    const capsJson = {
      'version': '16.1',
      'soc': {
        'name': 'mt6897',
        'arch': '4+3+1',
        'gpu_type': 'gpufreqv2',
        'ppm_version': 'none',
      },
      'features': {
        'eas': true,
        'uclamp': true,
        'dram_dvfs': true,
        'gbe': true,
        'fpsgo': true,
        'charge_bypass': true,
        'battery_care': true,
        'ufs': true,
      },
      'total_policies': 3,
      'cpu_policies': [
        {
          'id': 0,
          'cluster_name': 'Little Cluster',
          'cpu_label': 'cpu0-3',
          'path': '/sys/devices/system/cpu/cpufreq/policy0',
          'min_freq': 480000,
          'max_freq': 2200000,
          'cpus': [0, 1, 2, 3],
          'available_freqs': [2200000, 2100000, 480000],
          'available_governors': ['sugov_ext', 'schedutil'],
        },
        {
          'id': 1,
          'cluster_name': 'Mid Cluster',
          'cpu_label': 'cpu4-6',
          'path': '/sys/devices/system/cpu/cpufreq/policy4',
          'min_freq': 400000,
          'max_freq': 3200000,
          'cpus': [4, 5, 6],
          'available_freqs': [3200000, 2800000, 400000],
          'available_governors': ['sugov_ext', 'schedutil'],
        },
      ],
      'gpu': {
        'type': 'gpufreqv2',
        'freq_unit': 'kHz',
        'has_governor': false,
        'available_freqs': [1400000, 1222000, 265000],
        'available_governors': ['simple_ondemand'],
      },
      'dram': {
        'available': true,
        'available_freqs': [800000000, 2133000000],
        'available_governors': ['simple_ondemand'],
      },
      'ufs': {
        'available': true,
        'available_freqs': [273000000, 458333313],
        'available_governors': ['simple_ondemand'],
      },
    };

    test('parses full capabilities JSON correctly', () {
      final config = DeviceConfig.fromJson(capsJson);

      expect(config.socName, equals('mt6897'));
      expect(config.archType, equals('4+3+1'));
      expect(config.gpuType, equals('gpufreqv2'));
      expect(config.totalPolicies, equals(3));
      expect(config.policies.length, equals(2));

      // Policy 0
      expect(config.policies[0].index, equals(0));
      expect(config.policies[0].clusterName, equals('Little Cluster'));
      expect(config.policies[0].cpuLabel, equals('cpu0-3'));
      expect(config.policies[0].minFreq, equals(480000));
      expect(config.policies[0].maxFreq, equals(2200000));
      expect(config.policies[0].freqs, equals([2200000, 2100000, 480000]));
      expect(config.policies[0].governors, equals(['sugov_ext', 'schedutil']));

      // Features
      expect(config.hasEas, isTrue);
      expect(config.hasUclamp, isTrue);
      expect(config.hasGbe, isTrue);
      expect(config.hasFpsgo, isTrue);
      expect(config.hasChargeBypass, isTrue);
      expect(config.hasHardwareBypass, isTrue);
      expect(config.hasSmartFastCharge, isTrue);
      expect(config.hasBatteryCare, isTrue);

      // GPU
      expect(config.gpuFreqs, equals([1400000, 1222000, 265000]));
      expect(config.gpuGovernors, equals(['simple_ondemand']));
      expect(config.gpuFreqInKHz, isTrue);

      // DRAM
      expect(config.dvfAvailable, isTrue);
      expect(config.dvfFreqs, equals([800000000, 2133000000]));

      // UFS
      expect(config.ufsAvailable, isTrue);
      expect(config.ufsFreqs, equals([273000000, 458333313]));
    });

    test('handles daemon v16.4 smart_fast_charge and charge_suspend without hardware bypass', () {
      const v164Json = {
        'version': '16.4',
        'soc': {'name': 'mt6897'},
        'features': {
          'eas': true,
          'uclamp': true,
          'charge_bypass': false,
          'charge_suspend': true,
          'smart_fast_charge': true,
          'battery_care': true,
        },
      };

      final config = DeviceConfig.fromJson(v164Json);
      expect(config.hasChargeBypass, isTrue);
      expect(config.hasHardwareBypass, isFalse);
      expect(config.hasSmartFastCharge, isTrue);
      expect(config.hasBatteryCare, isTrue);
    });

    test('handles missing or partial feature flags safely', () {
      const partialJson = {
        'soc': {'name': 'mt6768'},
        'features': {
          'eas': false,
          'gbe': false,
          'charge_bypass': false,
        },
      };

      final config = DeviceConfig.fromJson(partialJson);
      expect(config.socName, equals('mt6768'));
      expect(config.hasEas, isFalse);
      expect(config.hasGbe, isFalse);
      expect(config.hasChargeBypass, isFalse);
      expect(config.hasHardwareBypass, isFalse);
      expect(config.policies, isEmpty);
      expect(config.gpuFreqs, isEmpty);
    });
  });
}
