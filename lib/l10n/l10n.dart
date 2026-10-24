import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/providers/shared_preferences_provider.dart';
import 'package:manager/l10n/generated/app_localizations.dart';

export 'package:manager/l10n/generated/app_localizations.dart';

/// `context.l10n.someKey` — typed access to the generated translations.
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Persisted UI language (`en` | `es`).
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  static const String _prefKey = 'app_locale';

  /// Key written by the `flutter_localization` package used before gen_l10n.
  static const String _legacyKey = 'translator_locale_key';
  static const String _legacyLanguageField = 'translator_language_code';

  @override
  Locale build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final code =
        prefs.getString(_prefKey) ??
        _legacyLanguage(prefs.getString(_legacyKey)) ??
        _systemLanguage();
    return Locale(_supported(code));
  }

  Future<void> setLanguage(String languageCode) async {
    final code = _supported(languageCode);
    state = Locale(code);
    await ref.read(sharedPreferencesProvider).setString(_prefKey, code);
  }

  static String _supported(String code) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == code)
      ? code
      : 'en';

  static String? _legacyLanguage(String? raw) {
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map[_legacyLanguageField] as String?;
    } on FormatException {
      return null;
    }
  }

  static String _systemLanguage() {
    try {
      return Platform.localeName.split(RegExp(r'[_-]')).first;
    } on Exception {
      return 'en';
    }
  }
}
