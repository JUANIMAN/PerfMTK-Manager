import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/perf_config/charge_thermal_card.dart';
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

  group('ChargeThermalCard Adaptive Naming and Sliders', () {
    testWidgets('displays Hardware Bypass title and min battery slider when hasHardwareBypass is true', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalization(
          ChargeThermalCard(
            bypassChargeThrottle: true,
            unlockFpsThermal: false,
            batteryTempLimit: 48,
            color: Colors.blue,
            hasChargeBypass: true,
            hasHardwareBypass: true,
            onChanged: ({
              required bool bypassChargeThrottle,
              required bool unlockFpsThermal,
              required int batteryTempLimit,
              required bool disableThermalServices,
              required int gentleChargeMa,
              required int bypassMinBattPct,
            }) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show Hardware Bypass title in Spanish ('Bypass de Carga (Hardware)')
      expect(find.text(AppLocale.hwChargeBypassTitle.getString(tester.element(find.byType(ChargeThermalCard)))), findsOneWidget);
      // Should show min battery level text
      expect(find.text(AppLocale.bypassMinBatt.getString(tester.element(find.byType(ChargeThermalCard)))), findsOneWidget);
    });

    testWidgets('displays Smart Fast Charge title and HIDES min battery slider when hasHardwareBypass is false', (tester) async {
      await tester.pumpWidget(
        _wrapWithLocalization(
          ChargeThermalCard(
            bypassChargeThrottle: true,
            unlockFpsThermal: false,
            batteryTempLimit: 48,
            color: Colors.blue,
            hasChargeBypass: true,
            hasHardwareBypass: false,
            onChanged: ({
              required bool bypassChargeThrottle,
              required bool unlockFpsThermal,
              required int batteryTempLimit,
              required bool disableThermalServices,
              required int gentleChargeMa,
              required int bypassMinBattPct,
            }) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show Smart Fast Charge title in Spanish ('Carga Rápida en Juegos')
      expect(find.text(AppLocale.smartFastChargeTitle.getString(tester.element(find.byType(ChargeThermalCard)))), findsOneWidget);
      // Min battery slider should be HIDDEN
      expect(find.text(AppLocale.bypassMinBatt.getString(tester.element(find.byType(ChargeThermalCard)))), findsNothing);
    });
  });
}
