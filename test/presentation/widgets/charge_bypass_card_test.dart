import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/screens/battery_screen.dart';
import 'package:manager/presentation/widgets/charge_bypass_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrapWithLocalization(Widget child) {
  final localization = FlutterLocalization.instance;
  return MaterialApp(
    supportedLocales: localization.supportedLocales,
    localizationsDelegates: localization.localizationsDelegates,
    home: Scaffold(
      body: SingleChildScrollView(
        child: child,
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await FlutterLocalization.instance.ensureInitialized();
    FlutterLocalization.instance.init(
      mapLocales: [
        MapLocale('en', AppLocale.en),
        MapLocale('es', AppLocale.es),
      ],
      initLanguageCode: 'es',
    );
  });

  group('ChargeBypassCard Adaptive Naming and Texts', () {
    testWidgets('displays Hardware Bypass title and active badge when hasHardwareBypass is true', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalization(
          ChargeBypassCard(
            isEnabled: true,
            hasHardwareBypass: true,
            batteryTempC: 34,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppLocale.hwChargeBypassTitle.getString(tester.element(find.byType(ChargeBypassCard)))), findsOneWidget);
      expect(find.text(AppLocale.hwBypassActive.getString(tester.element(find.byType(ChargeBypassCard)))), findsOneWidget);
      expect(find.text(AppLocale.hwChargeBypassDesc.getString(tester.element(find.byType(ChargeBypassCard)))), findsOneWidget);
    });

    testWidgets('displays Smart Fast Charge title and active badge when hasHardwareBypass is false', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalization(
          ChargeBypassCard(
            isEnabled: true,
            hasHardwareBypass: false,
            batteryTempC: 34,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppLocale.smartFastChargeTitle.getString(tester.element(find.byType(ChargeBypassCard)))), findsOneWidget);
      expect(find.text(AppLocale.smartFastChargeActive.getString(tester.element(find.byType(ChargeBypassCard)))), findsOneWidget);
      expect(find.text(AppLocale.smartFastChargeDesc.getString(tester.element(find.byType(ChargeBypassCard)))), findsOneWidget);
    });
  });

  group('Battery Hero Discharging vs Bypass Logic', () {
    testWidgets('shows Descargando and remaining time estimate when unplugged, even if chargeBypass flag is true', (tester) async {
      const state = SystemState(
        currentProfile: ProfileType.balanced,
        thermalState: ThermalState.enabled,
        chargeStatus: 'Discharging',
        chargeBypass: true,
        batteryCapacityPct: 89,
        chargeCurrentNowMa: 472,
        chargeVoltageNowMv: 4057,
        chargePowerW: 1.91,
        batteryTempC: 32,
        chargeFullMah: 5000,
        chargeCounterMah: 4450,
      );

      await tester.pumpWidget(
        _wrapWithLocalization(
          const LiveBatteryHeroCard(state: state, hasHardwareBypass: false),
        ),
      );
      await tester.pumpAndSettle();

      // Must display 'Descargando'
      expect(find.text('Descargando'), findsOneWidget);
      // Must NOT display 'Bypass Activo'
      expect(find.text('Bypass Activo'), findsNothing);
      // Must show calculated remaining time (~9 h 25 m de autonomía restante)
      expect(find.textContaining('de autonomía restante'), findsOneWidget);
      // Must NOT show direct AC feed banner
      expect(find.textContaining('Alimentación directa'), findsNothing);
    });

    testWidgets('shows Bypass Activo and direct power banner when charging with hardware bypass', (tester) async {
      const state = SystemState(
        currentProfile: ProfileType.performance,
        thermalState: ThermalState.enabled,
        chargeStatus: 'Charging',
        chargeBypass: true,
        batteryCapacityPct: 70,
        chargeCurrentNowMa: 200,
        chargeVoltageNowMv: 4200,
        chargePowerW: 5.0,
        batteryTempC: 35,
      );

      await tester.pumpWidget(
        _wrapWithLocalization(
          const LiveBatteryHeroCard(state: state, hasHardwareBypass: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bypass Activo'), findsOneWidget);
      expect(find.textContaining('Alimentación directa por cable'), findsOneWidget);
    });

    testWidgets('shows Carga Rápida and thermal override banner when charging with smart fast charge (no HW bypass)', (tester) async {
      const state = SystemState(
        currentProfile: ProfileType.performance,
        thermalState: ThermalState.enabled,
        chargeStatus: 'Charging',
        chargeBypass: true,
        batteryCapacityPct: 70,
        chargeCurrentNowMa: 3500,
        chargeVoltageNowMv: 4300,
        chargePowerW: 30.0,
        batteryTempC: 38,
      );

      await tester.pumpWidget(
        _wrapWithLocalization(
          const LiveBatteryHeroCard(state: state, hasHardwareBypass: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Carga Rápida'), findsOneWidget);
      expect(find.textContaining('Carga rápida en juegos activa'), findsOneWidget);
    });
  });
}
