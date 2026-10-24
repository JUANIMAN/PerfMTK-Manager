import 'package:manager/features/app_profiles/data/app_profile.dart';

/// Editable copy of an app's [AppDirectives] used by the profile sheet.
///
/// Fields are mutable on purpose: the sheet mutates them inside `setState`.
/// Directives the sheet does not expose (DRAM min, UCLAMP max) are preserved
/// from the original value when converting back.
class DirectivesDraft {
  DirectivesDraft.from(AppDirectives? source)
    : gbe = source?.gbe == 1,
      chargeBypass = source?.chargeBypass == true,
      disableThermal = source?.disableThermal == true,
      touchGameMode = source?.touchGameMode == true,
      renderBoost = source?.renderBoost == 1,
      gentleCharge = source?.gentleCharge,
      fps = source?.fps;

  bool gbe;
  bool chargeBypass;
  bool disableThermal;
  bool touchGameMode;
  bool renderBoost;
  int? gentleCharge;
  int? fps;

  int get activeCount =>
      [
        gbe,
        chargeBypass,
        disableThermal,
        touchGameMode,
        renderBoost,
        gentleCharge != null,
        fps != null,
      ].where((active) => active).length;

  void clear() {
    gbe = false;
    chargeBypass = false;
    disableThermal = false;
    touchGameMode = false;
    renderBoost = false;
    gentleCharge = null;
    fps = null;
  }

  /// [base] supplies the directives that are not editable here.
  AppDirectives toDirectives({AppDirectives? base}) => AppDirectives(
    gbe: gbe ? 1 : null,
    chargeBypass: chargeBypass ? true : null,
    disableThermal: disableThermal ? true : null,
    touchGameMode: touchGameMode ? true : null,
    dramMin: base?.dramMin,
    uclampMax: base?.uclampMax,
    gentleCharge: gentleCharge,
    renderBoost: renderBoost ? 1 : null,
    fps: fps,
  );
}
