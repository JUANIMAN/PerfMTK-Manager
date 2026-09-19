import 'package:installed_apps/app_info.dart';
import 'package:manager/data/models/profile.dart';

class AppDirectives {
  final int? gbe; // 0 = off, 1 = on
  final int? dramMin; // e.g. 5500000000
  final bool? chargeBypass; // true = on, false = off
  final int? uclampMax; // 0..100
  final int? gentleCharge; // e.g. 500
  final int? renderBoost; // 0 = off, 1 = on
  final int? fps; // e.g. 60, 90, 120
  final bool? disableThermal; // true = thermal off, false = thermal on
  final bool? touchGameMode; // true = game mode (480Hz + pin), false = default

  const AppDirectives({
    this.gbe,
    this.dramMin,
    this.chargeBypass,
    this.uclampMax,
    this.gentleCharge,
    this.renderBoost,
    this.fps,
    this.disableThermal,
    this.touchGameMode,
  });

  bool get isEmpty =>
      gbe == null &&
      dramMin == null &&
      chargeBypass == null &&
      uclampMax == null &&
      gentleCharge == null &&
      renderBoost == null &&
      fps == null &&
      disableThermal == null &&
      touchGameMode == null;

  bool get isNotEmpty => !isEmpty;

  AppDirectives copyWith({
    int? gbe,
    bool clearGbe = false,
    int? dramMin,
    bool clearDramMin = false,
    bool? chargeBypass,
    bool clearChargeBypass = false,
    int? uclampMax,
    bool clearUclampMax = false,
    int? gentleCharge,
    bool clearGentleCharge = false,
    int? renderBoost,
    bool clearRenderBoost = false,
    int? fps,
    bool clearFps = false,
    bool? disableThermal,
    bool clearDisableThermal = false,
    bool? touchGameMode,
    bool clearTouchGameMode = false,
  }) {
    return AppDirectives(
      gbe: clearGbe ? null : (gbe ?? this.gbe),
      dramMin: clearDramMin ? null : (dramMin ?? this.dramMin),
      chargeBypass:
          clearChargeBypass ? null : (chargeBypass ?? this.chargeBypass),
      uclampMax: clearUclampMax ? null : (uclampMax ?? this.uclampMax),
      gentleCharge:
          clearGentleCharge ? null : (gentleCharge ?? this.gentleCharge),
      renderBoost:
          clearRenderBoost ? null : (renderBoost ?? this.renderBoost),
      fps: clearFps ? null : (fps ?? this.fps),
      disableThermal:
          clearDisableThermal ? null : (disableThermal ?? this.disableThermal),
      touchGameMode:
          clearTouchGameMode ? null : (touchGameMode ?? this.touchGameMode),
    );
  }

  /// Parses from a string list of directives e.g. ["gbe=1", "charge_bypass=on", "gentle_charge=500"]
  static AppDirectives fromParts(List<String> parts) {
    int? gbe;
    int? dramMin;
    bool? chargeBypass;
    int? uclampMax;
    int? gentleCharge;
    int? renderBoost;
    int? fps;
    bool? disableThermal;
    bool? touchGameMode;

    for (final part in parts) {
      final eq = part.indexOf('=');
      if (eq < 1) continue;
      final k = part.substring(0, eq).trim().toLowerCase();
      final v = part.substring(eq + 1).trim().toLowerCase();

      if (k == 'gbe') {
        gbe = int.tryParse(v);
      } else if (k == 'dram_min') {
        dramMin = int.tryParse(v);
      } else if (k == 'charge_bypass') {
        chargeBypass = (v == 'on' || v == '1' || v == 'true');
      } else if (k == 'uclamp_max') {
        uclampMax = int.tryParse(v);
      } else if (k == 'gentle_charge') {
        gentleCharge = int.tryParse(v);
      } else if (k == 'render_boost') {
        renderBoost = int.tryParse(v);
      } else if (k == 'fps' || k == 'refresh') {
        fps = int.tryParse(v);
      } else if (k == 'thermal') {
        disableThermal = (v == 'off' || v == '0' || v == 'disable' || v == 'disabled');
      } else if (k == 'disable_thermal') {
        disableThermal = (v == 'true' || v == '1' || v == 'on');
      } else if (k == 'touch' || k == 'touch_boost') {
        touchGameMode = (v == 'game' || v == 'on' || v == '1' || v == 'true');
      }
    }

    return AppDirectives(
      gbe: gbe,
      dramMin: dramMin,
      chargeBypass: chargeBypass,
      uclampMax: uclampMax,
      gentleCharge: gentleCharge,
      renderBoost: renderBoost,
      fps: fps,
      disableThermal: disableThermal,
      touchGameMode: touchGameMode,
    );
  }

  /// Formats directives into ";gbe=1;charge_bypass=on;gentle_charge=500" format
  String toConfString() {
    final list = <String>[];
    if (gbe != null) list.add('gbe=$gbe');
    if (dramMin != null) list.add('dram_min=$dramMin');
    if (chargeBypass != null) {
      list.add('charge_bypass=${chargeBypass! ? 'on' : 'off'}');
    }
    if (uclampMax != null) list.add('uclamp_max=$uclampMax');
    if (gentleCharge != null) list.add('gentle_charge=$gentleCharge');
    if (renderBoost != null) list.add('render_boost=$renderBoost');
    if (fps != null) list.add('fps=$fps');
    if (disableThermal != null) {
      list.add('thermal=${disableThermal! ? 'off' : 'on'}');
    }
    if (touchGameMode != null) {
      list.add('touch=${touchGameMode! ? 'game' : 'default'}');
    }
    if (list.isEmpty) return '';
    return ';${list.join(';')}';
  }
}

class AppProfile {
  final AppInfo appInfo;
  final ProfileType? assignedProfile;
  final AppDirectives? directives;

  const AppProfile({
    required this.appInfo,
    this.assignedProfile,
    this.directives,
  });

  AppProfile copyWith({
    AppInfo? appInfo,
    ProfileType? assignedProfile,
    bool clearProfile = false,
    AppDirectives? directives,
    bool clearDirectives = false,
  }) {
    return AppProfile(
      appInfo: appInfo ?? this.appInfo,
      assignedProfile:
          clearProfile ? null : (assignedProfile ?? this.assignedProfile),
      directives:
          clearDirectives ? null : (directives ?? this.directives),
    );
  }

  bool get isConfigured => assignedProfile != null;
}
