import 'package:flutter_test/flutter_test.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/data/models/profile.dart';

void main() {
  group('SystemState parsing', () {
    test('parses battery_care and telemetry correctly from JSON', () {
      final json = {
        'version': '16.1',
        'active_profile': 'performance',
        'current_app': 'com.tencent.ig',
        'screen_on': true,
        'fg_engine': 'LSPosed Hook (Push)',
        'soc': {
          'name': 'mt6897',
          'arch': '4+3+1',
          'gpu_type': 'gpufreqv2',
        },
        'cpu_clusters': 'P0: 2200MHz | P1: 3000MHz | P2: 3350MHz',
        'gpu_freq': '1400MHz',
        'dram_freq': '2133MHz',
        'display_fps': 120,
        'charge': {
          'bypass': true,
          'mode': 'gentle',
          'gentle_charge_ma': 500,
          'battery_temp_c': 35,
          'battery_capacity': 85,
        },
        'battery_care': {
          'enabled': true,
          'limit_pct': 80,
          'suspended': true,
        },
        'temperatures': {
          'soc_c': 42.5,
          'battery_c': 35,
        },
        'uclamp': 'min: 1024 | max: max',
        'drivers_active': 8,
      };

      final state = SystemState.fromJson(json);

      expect(state.version, '16.1');
      expect(state.currentProfile, ProfileType.performance);
      expect(state.currentApp, 'com.tencent.ig');
      expect(state.chargeBypass, true);
      expect(state.chargeMode, 'gentle');
      expect(state.gentleChargeMa, 500);
      expect(state.batteryTempC, 35);
      expect(state.socTempC, 42.5);
      expect(state.batteryCapacityPct, 85);
      expect(state.batteryCareEnabled, true);
      expect(state.batteryCareLimitPct, 80);
      expect(state.batteryCareSuspended, true);
      expect(state.driversActive, 8);
    });

    test('handles missing battery_care block gracefully with defaults', () {
      final json = {
        'version': '16.1',
        'active_profile': 'balanced',
      };

      final state = SystemState.fromJson(json);

      expect(state.currentProfile, ProfileType.balanced);
      expect(state.batteryCareEnabled, false);
      expect(state.batteryCareLimitPct, 80);
      expect(state.batteryCareSuspended, false);
    });

    test('parses thermal_state directly from JSON if present', () {
      final jsonDisabled = {
        'version': '16.1',
        'active_profile': 'performance',
        'thermal_state': 'disabled',
      };
      final stateDisabled = SystemState.fromJson(jsonDisabled);
      expect(stateDisabled.thermalState, ThermalState.disabled);

      final jsonEnabled = {
        'version': '16.1',
        'active_profile': 'powersave',
        'thermal_state': 'enabled',
      };
      final stateEnabled = SystemState.fromJson(jsonEnabled);
      expect(stateEnabled.thermalState, ThermalState.enabled);
    });

    test('parses thermal_guardian block correctly from JSON', () {
      final json = {
        'version': '16.1',
        'active_profile': 'performance',
        'thermal_guardian': {
          'enabled': true,
          'status': 'clamping (step 1/2)',
          'target_temp_c': 75,
          'clamp_step': 1,
          'max_steps': 2,
          'trend_c_s': 0.42,
        },
      };

      final state = SystemState.fromJson(json);

      expect(state.thermalGuardianEnabled, true);
      expect(state.thermalGuardianStatus, 'clamping (step 1/2)');
      expect(state.thermalGuardianTargetC, 75);
      expect(state.thermalGuardianClampStep, 1);
      expect(state.thermalGuardianMaxSteps, 2);
      expect(state.thermalGuardianTrend, 0.42);
    });

    test('handles missing thermal_guardian block gracefully with defaults', () {
      final json = {
        'version': '16.1',
        'active_profile': 'balanced',
      };

      final state = SystemState.fromJson(json);

      expect(state.thermalGuardianEnabled, false);
      expect(state.thermalGuardianStatus, 'disabled');
      expect(state.thermalGuardianTargetC, 75);
      expect(state.thermalGuardianClampStep, 0);
      expect(state.thermalGuardianMaxSteps, 2);
      expect(state.thermalGuardianTrend, 0.0);
    });
  });
}
