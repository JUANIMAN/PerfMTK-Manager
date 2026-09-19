import 'package:flutter_test/flutter_test.dart';
import 'package:manager/localization/app_locales.dart';

void main() {
  group('AppLocale Parity Tests', () {
    test('en and es have identical key sets', () {
      final enKeys = AppLocale.en.keys.toSet();
      final esKeys = AppLocale.es.keys.toSet();

      final missingInEs = enKeys.difference(esKeys);
      final missingInEn = esKeys.difference(enKeys);

      expect(
        missingInEs,
        isEmpty,
        reason: 'Keys present in en but missing in es: $missingInEs',
      );
      expect(
        missingInEn,
        isEmpty,
        reason: 'Keys present in es but missing in en: $missingInEn',
      );
    });

    test('no keys have empty or whitespace-only values', () {
      for (final entry in AppLocale.en.entries) {
        expect(
          entry.value.toString().trim(),
          isNotEmpty,
          reason: 'en key "${entry.key}" is empty',
        );
      }
      for (final entry in AppLocale.es.entries) {
        expect(
          entry.value.toString().trim(),
          isNotEmpty,
          reason: 'es key "${entry.key}" is empty',
        );
      }
    });

    test('v16.3 keys are properly populated in both locales', () {
      const v163Keys = [
        AppLocale.minFreq,
        AppLocale.maxFreq,
        AppLocale.governor,
        AppLocale.onlineCores,
        AppLocale.freqMode,
        AppLocale.dvfsAuto,
        AppLocale.fixedFreq,
        AppLocale.minFreqDram,
        AppLocale.ufsClkEnable,
        AppLocale.clockEnabled,
        AppLocale.clockDisabled,
        AppLocale.rateLimits,
        AppLocale.downRateLimit,
        AppLocale.upRateLimit,
        AppLocale.forceOnOff,
        AppLocale.offOption,
        AppLocale.onOption,
        AppLocale.freeOption,
        AppLocale.taBoost,
        AppLocale.taBoostEnabled,
        AppLocale.taBoostDisabled,
        AppLocale.gbeActiveDesc,
        AppLocale.gbeInactiveDesc,
        AppLocale.bypassChargeActiveDesc,
        AppLocale.bypassChargeInactiveDesc,
        AppLocale.unlockFpsActiveDesc,
        AppLocale.unlockFpsInactiveDesc,
        AppLocale.batterySafetyGuard,
        AppLocale.gbeDirectiveSubtitle,
        AppLocale.bypassDirectiveSubtitle,
        AppLocale.modeGlobal,
        AppLocale.gpuCore,
        AppLocale.busDram,
        AppLocale.revertChanges,
        AppLocale.systemAppTag,
        AppLocale.tabPerf,
        AppLocale.tabBalanced,
        AppLocale.tabPowersave,
        AppLocale.tabPowersavePlus,
      ];

      for (final key in v163Keys) {
        expect(AppLocale.en.containsKey(key), isTrue, reason: 'Missing in en: $key');
        expect(AppLocale.es.containsKey(key), isTrue, reason: 'Missing in es: $key');
      }
    });
  });
}
