import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/perf_config/presentation/widgets/charge_thermal_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrapWithLocalization(Widget child) {
  return MaterialApp(
    locale: const Locale('es'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
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
      expect(find.text(tester.element(find.byType(ChargeThermalCard)).l10n.hwChargeBypassTitle), findsOneWidget);
      // Should show min battery level text
      expect(find.text(tester.element(find.byType(ChargeThermalCard)).l10n.bypassMinBatt), findsOneWidget);
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
      expect(find.text(tester.element(find.byType(ChargeThermalCard)).l10n.smartFastChargeTitle), findsOneWidget);
      // Min battery slider should be HIDDEN
      expect(find.text(tester.element(find.byType(ChargeThermalCard)).l10n.bypassMinBatt), findsNothing);
    });
  });
}
