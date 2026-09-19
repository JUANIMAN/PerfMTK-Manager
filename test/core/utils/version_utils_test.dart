import 'package:flutter_test/flutter_test.dart';
import 'package:manager/core/utils/version_utils.dart';

void main() {
  group('isVersionNewer', () {
    test('compares versions with different component counts', () {
      expect(isVersionNewer('v7.1', '7.0.9'), isTrue);
      expect(isVersionNewer('7.0', '7.0.0'), isFalse);
    });

    test('ignores build metadata', () {
      expect(isVersionNewer('7.0.1+12', '7.0.0+99'), isTrue);
      expect(isVersionNewer('7.0.0+12', '7.0.0+1'), isFalse);
    });

    test('treats a release as newer than the same prerelease', () {
      expect(isVersionNewer('7.0.0', '7.0.0-beta.1'), isTrue);
      expect(isVersionNewer('7.0.0-beta.2', '7.0.0'), isFalse);
    });

    test('does not throw for malformed tags', () {
      expect(isVersionNewer('latest', '7.0.0'), isFalse);
      expect(isVersionNewer('7.x.0', '7.0.0'), isFalse);
    });
  });
}
