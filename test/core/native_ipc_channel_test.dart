import 'package:flutter_test/flutter_test.dart';
import 'package:manager/core/native_ipc_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NativeIpcChannel', () {
    test('singleton instance is persistent', () {
      final a = NativeIpcChannel();
      final b = NativeIpcChannel();
      expect(identical(a, b), true);
    });

    test('isAvailable returns false on non-Android test environment without throwing', () async {
      final channel = NativeIpcChannel();
      channel.resetAvailability();
      final available = await channel.isAvailable();
      expect(available, false);
    });

    test('sendCommand returns null on non-Android platform safely', () async {
      final channel = NativeIpcChannel();
      final res = await channel.sendCommand('PING');
      expect(res, null);
    });

    test('isDaemonRunning returns false on non-Android platform safely', () async {
      final channel = NativeIpcChannel();
      final running = await channel.isDaemonRunning();
      expect(running, false);
    });

    test('streamTelemetry returns empty stream on non-Android platform', () async {
      final channel = NativeIpcChannel();
      final items = await channel.streamTelemetry().toList();
      expect(items.isEmpty, true);
    });
  });
}
