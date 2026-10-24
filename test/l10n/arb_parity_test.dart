import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

Set<String> _placeholders(String message) =>
    RegExp(r'\{(\w+)\}').allMatches(message).map((m) => m.group(1)!).toSet();

void main() {
  final en = _arb('en');
  final es = _arb('es');

  group('ARB parity', () {
    test('en and es have identical message keys', () {
      final enKeys = _messageKeys(en);
      final esKeys = _messageKeys(es);

      expect(
        enKeys.difference(esKeys),
        isEmpty,
        reason: 'present in en but missing in es',
      );
      expect(
        esKeys.difference(enKeys),
        isEmpty,
        reason: 'present in es but missing in en',
      );
    });

    test('no message is empty', () {
      for (final entry in {...en}.entries.followedBy(es.entries)) {
        if (entry.key.startsWith('@')) continue;
        expect(
          (entry.value as String).trim(),
          isNotEmpty,
          reason: '"${entry.key}" is empty',
        );
      }
    });

    test('both languages use the same placeholders', () {
      for (final key in _messageKeys(en)) {
        expect(
          _placeholders(es[key] as String),
          _placeholders(en[key] as String),
          reason: 'placeholder mismatch for "$key"',
        );
      }
    });

    test('every placeholder is declared in the template metadata', () {
      for (final key in _messageKeys(en)) {
        final used = _placeholders(en[key] as String);
        if (used.isEmpty) continue;
        final meta = en['@$key'] as Map<String, dynamic>?;
        final declared =
            ((meta?['placeholders'] as Map<String, dynamic>?) ?? {}).keys
                .toSet();
        expect(declared, used, reason: 'metadata mismatch for "$key"');
      }
    });
  });
}
