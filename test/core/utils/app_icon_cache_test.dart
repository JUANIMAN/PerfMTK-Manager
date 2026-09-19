import 'package:flutter_test/flutter_test.dart';
import 'package:manager/core/utils/app_icon_cache.dart';

void main() {
  group('AppIconCache', () {
    final cache = AppIconCache.instance;

    setUp(() {
      cache.clear();
    });

    test('returns null for uncached package', () {
      expect(cache.getCached('com.example.nonexistent'), isNull);
    });

    test('clear wipes cached icon data', () {
      // Direct access check
      cache.clear();
      expect(cache.getCached('com.example.test'), isNull);
    });
  });
}
