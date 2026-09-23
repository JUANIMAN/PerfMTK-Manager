import 'package:manager/data/models/profile.dart';

enum ThermalState {
  enabled('enabled'),
  disabled('disabled');

  const ThermalState(this.value);
  final String value;

  static ThermalState fromString(String value) {
    return ThermalState.values
        .firstWhere((state) => state.value == value,
        orElse: () => ThermalState.enabled);
  }
}

class SystemState {
  final ProfileType currentProfile;
  final ThermalState thermalState;
  final String version;
  final String currentApp;
  final bool screenOn;
  final String fgEngine;
  final String socName;
  final String socArch;
  final String gpuType;
  final String cpuClusters;
  final String gpuFreq;
  final String dramFreq;
  final bool chargeBypass;
  final String chargeMode;
  final int? gentleChargeMa;
  final int? batteryTempC;
  final double? socTempC;
  final String uclamp;
  final int driversActive;
  final int? displayFps;
  final int? gameFps;
  final int? batteryCapacityPct;
  final bool batteryCareEnabled;
  final int batteryCareLimitPct;
  final bool batteryCareSuspended;
  final bool thermalGuardianEnabled;
  final String thermalGuardianStatus;
  final int thermalGuardianTargetC;
  final int thermalGuardianClampStep;
  final int thermalGuardianMaxSteps;
  final double thermalGuardianTrend;

  const SystemState({
    required this.currentProfile,
    required this.thermalState,
    this.version = '',
    this.currentApp = '',
    this.screenOn = true,
    this.fgEngine = '',
    this.socName = '',
    this.socArch = '',
    this.gpuType = '',
    this.cpuClusters = '',
    this.gpuFreq = '',
    this.dramFreq = '',
    this.chargeBypass = false,
    this.chargeMode = 'normal',
    this.gentleChargeMa,
    this.batteryTempC,
    this.socTempC,
    this.uclamp = '',
    this.driversActive = 0,
    this.displayFps,
    this.gameFps,
    this.batteryCapacityPct,
    this.batteryCareEnabled = false,
    this.batteryCareLimitPct = 80,
    this.batteryCareSuspended = false,
    this.thermalGuardianEnabled = false,
    this.thermalGuardianStatus = 'disabled',
    this.thermalGuardianTargetC = 75,
    this.thermalGuardianClampStep = 0,
    this.thermalGuardianMaxSteps = 2,
    this.thermalGuardianTrend = 0.0,
  });

  factory SystemState.fromJson(
    Map<String, dynamic> json, {
    ThermalState? thermalState,
  }) {
    final activeProfileStr = json['active_profile'] as String? ?? '';
    final resolvedThermal = thermalState ??
        (json['thermal_state'] != null
            ? ThermalState.fromString(json['thermal_state'] as String)
            : ThermalState.enabled);
    final soc = json['soc'] is Map ? json['soc'] as Map<String, dynamic> : null;
    final charge =
        json['charge'] is Map ? json['charge'] as Map<String, dynamic> : null;
    final temps =
        json['temperatures'] is Map
            ? json['temperatures'] as Map<String, dynamic>
            : null;

    int? battTemp;
    if (charge?['battery_temp_c'] != null) {
      battTemp = (charge!['battery_temp_c'] as num).toInt();
    } else if (temps?['battery_c'] != null) {
      battTemp = (temps!['battery_c'] as num).toInt();
    }

    double? socTemp;
    if (temps?['soc_c'] != null) {
      socTemp = (temps!['soc_c'] as num).toDouble();
    }

    final int? battCap = (charge?['battery_capacity'] as num?)?.toInt();
    final int? dispFps = (json['display_fps'] as num?)?.toInt();
    final int? gFps = (json['game_fps'] as num?)?.toInt();

    final batteryCare =
        json['battery_care'] is Map
            ? json['battery_care'] as Map<String, dynamic>
            : null;
    final bool careEnabled = batteryCare?['enabled'] as bool? ?? false;
    final int careLimit = (batteryCare?['limit_pct'] as num?)?.toInt() ?? 80;
    final bool careSuspended = batteryCare?['suspended'] as bool? ?? false;

    final tg =
        json['thermal_guardian'] is Map
            ? json['thermal_guardian'] as Map<String, dynamic>
            : null;
    final bool tgEnabled = tg?['enabled'] as bool? ?? false;
    final String tgStatus = tg?['status'] as String? ?? 'disabled';
    final int tgTarget = (tg?['target_temp_c'] as num?)?.toInt() ?? 75;
    final int tgStep = (tg?['clamp_step'] as num?)?.toInt() ?? 0;
    final int tgMaxSteps = (tg?['max_steps'] as num?)?.toInt() ?? 2;
    final double tgTrend = (tg?['trend_c_s'] as num?)?.toDouble() ?? 0.0;

    final String chgMode = charge?['mode'] as String? ??
        ((charge?['bypass'] as bool? ?? false) ? 'bypass' : 'normal');
    final int? gentleMa = (charge?['gentle_charge_ma'] as num?)?.toInt();

    return SystemState(
      currentProfile: ProfileType.fromString(activeProfileStr),
      thermalState: resolvedThermal,
      version: json['version'] as String? ?? '',
      currentApp: json['current_app'] as String? ?? '',
      screenOn: json['screen_on'] as bool? ?? true,
      fgEngine: json['fg_engine'] as String? ?? '',
      socName: soc?['name'] as String? ?? '',
      socArch: soc?['arch'] as String? ?? '',
      gpuType: soc?['gpu_type'] as String? ?? '',
      cpuClusters: json['cpu_clusters'] as String? ?? '',
      gpuFreq: json['gpu_freq'] as String? ?? '',
      dramFreq: json['dram_freq'] as String? ?? '',
      chargeBypass: charge?['bypass'] as bool? ?? false,
      chargeMode: chgMode,
      gentleChargeMa: gentleMa,
      batteryTempC: battTemp,
      socTempC: socTemp,
      uclamp: json['uclamp'] as String? ?? '',
      driversActive: (json['drivers_active'] as num?)?.toInt() ?? 0,
      displayFps: dispFps,
      gameFps: (gFps != null && gFps > 0) ? gFps : null,
      batteryCapacityPct: battCap,
      batteryCareEnabled: careEnabled,
      batteryCareLimitPct: careLimit,
      batteryCareSuspended: careSuspended,
      thermalGuardianEnabled: tgEnabled,
      thermalGuardianStatus: tgStatus,
      thermalGuardianTargetC: tgTarget,
      thermalGuardianClampStep: tgStep,
      thermalGuardianMaxSteps: tgMaxSteps,
      thermalGuardianTrend: tgTrend,
    );
  }

  SystemState copyWith({
    ProfileType? currentProfile,
    ThermalState? thermalState,
    String? version,
    String? currentApp,
    bool? screenOn,
    String? fgEngine,
    String? socName,
    String? socArch,
    String? gpuType,
    String? cpuClusters,
    String? gpuFreq,
    String? dramFreq,
    bool? chargeBypass,
    String? chargeMode,
    int? gentleChargeMa,
    int? batteryTempC,
    double? socTempC,
    String? uclamp,
    int? driversActive,
    int? displayFps,
    int? gameFps,
    int? batteryCapacityPct,
    bool? batteryCareEnabled,
    int? batteryCareLimitPct,
    bool? batteryCareSuspended,
    bool? thermalGuardianEnabled,
    String? thermalGuardianStatus,
    int? thermalGuardianTargetC,
    int? thermalGuardianClampStep,
    int? thermalGuardianMaxSteps,
    double? thermalGuardianTrend,
  }) {
    return SystemState(
      currentProfile: currentProfile ?? this.currentProfile,
      thermalState: thermalState ?? this.thermalState,
      version: version ?? this.version,
      currentApp: currentApp ?? this.currentApp,
      screenOn: screenOn ?? this.screenOn,
      fgEngine: fgEngine ?? this.fgEngine,
      socName: socName ?? this.socName,
      socArch: socArch ?? this.socArch,
      gpuType: gpuType ?? this.gpuType,
      cpuClusters: cpuClusters ?? this.cpuClusters,
      gpuFreq: gpuFreq ?? this.gpuFreq,
      dramFreq: dramFreq ?? this.dramFreq,
      chargeBypass: chargeBypass ?? this.chargeBypass,
      chargeMode: chargeMode ?? this.chargeMode,
      gentleChargeMa: gentleChargeMa ?? this.gentleChargeMa,
      batteryTempC: batteryTempC ?? this.batteryTempC,
      socTempC: socTempC ?? this.socTempC,
      uclamp: uclamp ?? this.uclamp,
      driversActive: driversActive ?? this.driversActive,
      displayFps: displayFps ?? this.displayFps,
      gameFps: gameFps ?? this.gameFps,
      batteryCapacityPct: batteryCapacityPct ?? this.batteryCapacityPct,
      batteryCareEnabled: batteryCareEnabled ?? this.batteryCareEnabled,
      batteryCareLimitPct: batteryCareLimitPct ?? this.batteryCareLimitPct,
      batteryCareSuspended: batteryCareSuspended ?? this.batteryCareSuspended,
      thermalGuardianEnabled:
          thermalGuardianEnabled ?? this.thermalGuardianEnabled,
      thermalGuardianStatus:
          thermalGuardianStatus ?? this.thermalGuardianStatus,
      thermalGuardianTargetC:
          thermalGuardianTargetC ?? this.thermalGuardianTargetC,
      thermalGuardianClampStep:
          thermalGuardianClampStep ?? this.thermalGuardianClampStep,
      thermalGuardianMaxSteps:
          thermalGuardianMaxSteps ?? this.thermalGuardianMaxSteps,
      thermalGuardianTrend:
          thermalGuardianTrend ?? this.thermalGuardianTrend,
    );
  }
}
