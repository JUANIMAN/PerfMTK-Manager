import 'dart:convert';
import 'dart:typed_data';
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
  final String chargeStatus;
  final int? chargeCurrentNowMa;
  final int? chargeVoltageNowMv;
  final double? chargePowerW;
  final int? chargeCurrentLimitMa;
  final int? gentleChargeMa;
  final int? batteryTempC;
  final double? socTempC;
  final String uclamp;
  final int driversActive;
  final int? displayFps;
  final int? gameFps;
  final int? batteryCapacityPct;
  final int? batteryCycleCount;
  final int? batterySohPct;
  final int? chargeFullMah;
  final int? chargeDesignMah;
  final int? chargeCounterMah;
  final bool batteryCareEnabled;
  final int batteryCareLimitPct;
  final bool batteryCareSuspended;
  final bool thermalGuardianEnabled;
  final String thermalGuardianStatus;
  final int thermalGuardianTargetC;
  final int thermalGuardianClampStep;
  final int thermalGuardianMaxSteps;
  final double thermalGuardianTrend;
  final bool backgroundJailed;
  final List<Map<String, dynamic>> pinnedThreads;

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
    this.chargeStatus = 'Discharging',
    this.chargeCurrentNowMa,
    this.chargeVoltageNowMv,
    this.chargePowerW,
    this.chargeCurrentLimitMa,
    this.gentleChargeMa,
    this.batteryTempC,
    this.socTempC,
    this.uclamp = '',
    this.driversActive = 0,
    this.displayFps,
    this.gameFps,
    this.batteryCapacityPct,
    this.batteryCycleCount,
    this.batterySohPct,
    this.chargeFullMah,
    this.chargeDesignMah,
    this.chargeCounterMah,
    this.batteryCareEnabled = false,
    this.batteryCareLimitPct = 80,
    this.batteryCareSuspended = false,
    this.thermalGuardianEnabled = false,
    this.thermalGuardianStatus = 'disabled',
    this.thermalGuardianTargetC = 75,
    this.thermalGuardianClampStep = 0,
    this.thermalGuardianMaxSteps = 2,
    this.thermalGuardianTrend = 0.0,
    this.backgroundJailed = false,
    this.pinnedThreads = const [],
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
    final int? battCycles = (charge?['cycle_count'] as num?)?.toInt();
    final int? battSoh = (charge?['soh_pct'] as num?)?.toInt();
    final int? chgFullMah = (charge?['charge_full_mah'] as num?)?.toInt();
    final int? chgDesignMah = (charge?['charge_design_mah'] as num?)?.toInt();
    final int? chgCounterMah = (charge?['charge_counter_mah'] as num?)?.toInt();
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
    final String chgStatus = charge?['status'] as String? ?? 'Discharging';
    final int? chgCurrentMa = (charge?['current_now_ma'] as num?)?.toInt();
    final int? chgVoltageMv = (charge?['voltage_now_mv'] as num?)?.toInt();
    final double? chgPowerW = (charge?['power_w'] as num?)?.toDouble();
    final int? chgLimitMa = (charge?['current_limit_ma'] as num?)?.toInt();
    final int? gentleMa = (charge?['gentle_charge_ma'] as num?)?.toInt();
    final bool bgJailed = json['background_jailed'] as bool? ?? false;
    final List<Map<String, dynamic>> threads = (json['pinned_threads'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        const [];

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
      chargeStatus: chgStatus,
      chargeCurrentNowMa: chgCurrentMa,
      chargeVoltageNowMv: chgVoltageMv,
      chargePowerW: chgPowerW,
      chargeCurrentLimitMa: chgLimitMa,
      gentleChargeMa: gentleMa,
      batteryTempC: battTemp,
      socTempC: socTemp,
      uclamp: json['uclamp'] as String? ?? '',
      driversActive: (json['drivers_active'] as num?)?.toInt() ?? 0,
      displayFps: dispFps,
      gameFps: (gFps != null && gFps > 0) ? gFps : null,
      batteryCapacityPct: battCap,
      batteryCycleCount: (battCycles != null && battCycles >= 0) ? battCycles : null,
      batterySohPct: (battSoh != null && battSoh > 0) ? battSoh : null,
      chargeFullMah: (chgFullMah != null && chgFullMah > 0) ? chgFullMah : null,
      chargeDesignMah: (chgDesignMah != null && chgDesignMah > 0) ? chgDesignMah : null,
      chargeCounterMah: (chgCounterMah != null && chgCounterMah > 0) ? chgCounterMah : null,
      batteryCareEnabled: careEnabled,
      batteryCareLimitPct: careLimit,
      batteryCareSuspended: careSuspended,
      thermalGuardianEnabled: tgEnabled,
      thermalGuardianStatus: tgStatus,
      thermalGuardianTargetC: tgTarget,
      thermalGuardianClampStep: tgStep,
      thermalGuardianMaxSteps: tgMaxSteps,
      thermalGuardianTrend: tgTrend,
      backgroundJailed: bgJailed,
      pinnedThreads: threads,
    );
  }

  static const int shmMagic = 0x504D544B; // "PMTK"
  static const int shmVersion = 1;
  static const int shmStructSize = 2784;

  static String _readCString(Uint8List bytes, int offset, int maxLen) {
    int end = offset;
    final limit = offset + maxLen;
    while (end < limit && end < bytes.length && bytes[end] != 0) {
      end++;
    }
    if (end <= offset) return '';
    return utf8.decode(
      Uint8List.sublistView(bytes, offset, end),
      allowMalformed: true,
    );
  }

  /// Decodes a 2784-byte binary snapshot directly from `PerfMTKSharedTelemetry` (Zero-Copy SHM).
  static SystemState? fromShmBytes(Uint8List bytes, [ByteData? view]) {
    if (bytes.length < shmStructSize) return null;
    final bd = view ?? ByteData.sublistView(bytes);

    final magic = bd.getUint32(0, Endian.host);
    final structVersion = bd.getUint32(4, Endian.host);
    if (magic != shmMagic || structVersion != shmVersion) return null;

    final flags = bd.getUint32(12, Endian.host);
    final screenOn = (flags & (1 << 0)) != 0;
    final chargeBypass = (flags & (1 << 1)) != 0;
    final batteryCareEnabled = (flags & (1 << 2)) != 0;
    final batteryCareSuspended = (flags & (1 << 3)) != 0;
    final backgroundJailed = (flags & (1 << 4)) != 0;
    final thermalEnabled = (flags & (1 << 5)) != 0;

    final driversActive = bd.getInt32(24, Endian.host);
    final displayFps = bd.getInt32(28, Endian.host);
    final gameFps = bd.getInt32(32, Endian.host);
    final batteryTempC = bd.getInt32(36, Endian.host);
    final socTempMdeg = bd.getInt32(40, Endian.host);
    final batteryCapPct = bd.getInt32(44, Endian.host);
    final cycleCount = bd.getInt32(48, Endian.host);
    final sohPct = bd.getInt32(52, Endian.host);
    final chargeFullMah = bd.getInt32(56, Endian.host);
    final chargeDesignMah = bd.getInt32(60, Endian.host);

    final chargeCounterMah = bd.getInt32(64, Endian.host);
    final chargeCurrentNowMa = bd.getInt32(68, Endian.host);
    final chargeVoltageNowMv = bd.getInt32(72, Endian.host);
    final chargePowerMw = bd.getInt32(76, Endian.host);
    final chargeCurrentLimitMa = bd.getInt32(80, Endian.host);
    final gentleChargeMa = bd.getInt32(84, Endian.host);
    final batteryCareLimitPct = bd.getInt32(88, Endian.host);
    final pinnedThreadsCount = bd.getInt32(92, Endian.host).clamp(0, 32);

    final version = _readCString(bytes, 96, 16);
    final activeProfileStr = _readCString(bytes, 112, 32);
    final currentApp = _readCString(bytes, 144, 128);
    final fgEngine = _readCString(bytes, 272, 48);
    final socName = _readCString(bytes, 320, 32);
    final socArch = _readCString(bytes, 352, 32);
    final gpuType = _readCString(bytes, 384, 32);
    final cpuClusters = _readCString(bytes, 416, 128);
    final gpuFreq = _readCString(bytes, 544, 32);
    final dramFreq = _readCString(bytes, 576, 32);
    final uclamp = _readCString(bytes, 608, 64);
    final chargeMode = _readCString(bytes, 672, 32);
    final chargeStatus = _readCString(bytes, 704, 32);

    final threads = <Map<String, dynamic>>[];
    for (int i = 0; i < pinnedThreadsCount; i++) {
      final base = 736 + (i * 64);
      final tid = bd.getInt32(base, Endian.host);
      if (tid <= 0) continue;
      final name = _readCString(bytes, base + 4, 28);
      final role = _readCString(bytes, base + 32, 32);
      threads.add({
        'tid': tid,
        'name': name,
        'role': role,
      });
    }

    return SystemState(
      currentProfile: ProfileType.fromString(activeProfileStr),
      thermalState:
          thermalEnabled ? ThermalState.enabled : ThermalState.disabled,
      version: version,
      currentApp: currentApp,
      screenOn: screenOn,
      fgEngine: fgEngine,
      socName: socName,
      socArch: socArch,
      gpuType: gpuType,
      cpuClusters: cpuClusters,
      gpuFreq: gpuFreq,
      dramFreq: dramFreq,
      chargeBypass: chargeBypass,
      chargeMode: chargeMode.isNotEmpty
          ? chargeMode
          : (chargeBypass ? 'bypass' : 'normal'),
      chargeStatus: chargeStatus.isNotEmpty ? chargeStatus : 'Discharging',
      chargeCurrentNowMa: chargeCurrentNowMa,
      chargeVoltageNowMv: chargeVoltageNowMv,
      chargePowerW: chargePowerMw / 1000.0,
      chargeCurrentLimitMa: chargeCurrentLimitMa,
      gentleChargeMa: gentleChargeMa,
      batteryTempC: batteryTempC,
      socTempC: socTempMdeg > 0 ? socTempMdeg / 1000.0 : null,
      uclamp: uclamp,
      driversActive: driversActive,
      displayFps: displayFps > 0 ? displayFps : null,
      gameFps: gameFps > 0 ? gameFps : null,
      batteryCapacityPct: batteryCapPct,
      batteryCycleCount: cycleCount >= 0 ? cycleCount : null,
      batterySohPct: sohPct > 0 ? sohPct : null,
      chargeFullMah: chargeFullMah > 0 ? chargeFullMah : null,
      chargeDesignMah: chargeDesignMah > 0 ? chargeDesignMah : null,
      chargeCounterMah: chargeCounterMah > 0 ? chargeCounterMah : null,
      batteryCareEnabled: batteryCareEnabled,
      batteryCareLimitPct:
          batteryCareLimitPct > 0 ? batteryCareLimitPct : 80,
      batteryCareSuspended: batteryCareSuspended,
      backgroundJailed: backgroundJailed,
      pinnedThreads: threads,
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
    String? chargeStatus,
    int? chargeCurrentNowMa,
    int? chargeVoltageNowMv,
    double? chargePowerW,
    int? chargeCurrentLimitMa,
    int? gentleChargeMa,
    int? batteryTempC,
    double? socTempC,
    String? uclamp,
    int? driversActive,
    int? displayFps,
    int? gameFps,
    int? batteryCapacityPct,
    int? batteryCycleCount,
    int? batterySohPct,
    int? chargeFullMah,
    int? chargeDesignMah,
    int? chargeCounterMah,
    bool? batteryCareEnabled,
    int? batteryCareLimitPct,
    bool? batteryCareSuspended,
    bool? thermalGuardianEnabled,
    String? thermalGuardianStatus,
    int? thermalGuardianTargetC,
    int? thermalGuardianClampStep,
    int? thermalGuardianMaxSteps,
    double? thermalGuardianTrend,
    bool? backgroundJailed,
    List<Map<String, dynamic>>? pinnedThreads,
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
      chargeStatus: chargeStatus ?? this.chargeStatus,
      chargeCurrentNowMa: chargeCurrentNowMa ?? this.chargeCurrentNowMa,
      chargeVoltageNowMv: chargeVoltageNowMv ?? this.chargeVoltageNowMv,
      chargePowerW: chargePowerW ?? this.chargePowerW,
      chargeCurrentLimitMa: chargeCurrentLimitMa ?? this.chargeCurrentLimitMa,
      gentleChargeMa: gentleChargeMa ?? this.gentleChargeMa,
      batteryTempC: batteryTempC ?? this.batteryTempC,
      socTempC: socTempC ?? this.socTempC,
      uclamp: uclamp ?? this.uclamp,
      driversActive: driversActive ?? this.driversActive,
      displayFps: displayFps ?? this.displayFps,
      gameFps: gameFps ?? this.gameFps,
      batteryCapacityPct: batteryCapacityPct ?? this.batteryCapacityPct,
      batteryCycleCount: batteryCycleCount ?? this.batteryCycleCount,
      batterySohPct: batterySohPct ?? this.batterySohPct,
      chargeFullMah: chargeFullMah ?? this.chargeFullMah,
      chargeDesignMah: chargeDesignMah ?? this.chargeDesignMah,
      chargeCounterMah: chargeCounterMah ?? this.chargeCounterMah,
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
      backgroundJailed: backgroundJailed ?? this.backgroundJailed,
      pinnedThreads: pinnedThreads ?? this.pinnedThreads,
    );
  }
}
