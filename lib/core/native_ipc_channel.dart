import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

/// Direct Native IPC channel communicating with `@perfmtkd_ctrl` abstract socket
/// via Android LocalSocket, bypassing `su` process forks.
class NativeIpcChannel {
  static const MethodChannel _methodChannel =
      MethodChannel('com.perfmtk.manager/ipc');
  static const EventChannel _eventChannel =
      EventChannel('com.perfmtk.manager/telemetry_stream');

  static final NativeIpcChannel _instance = NativeIpcChannel._internal();
  factory NativeIpcChannel() => _instance;
  NativeIpcChannel._internal();

  bool? _isChannelSupported;

  /// Checks if the native platform channel is supported and reachable.
  Future<bool> isAvailable() async {
    if (!Platform.isAndroid) return false;
    if (_isChannelSupported != null) return _isChannelSupported!;

    try {
      final running = await isDaemonRunning();
      _isChannelSupported = running;
      return running;
    } catch (_) {
      _isChannelSupported = false;
      return false;
    }
  }

  /// Sends a raw command to the native daemon via abstract LocalSocket.
  /// Returns the string response or null if the socket or platform call fails.
  Future<String?> sendCommand(String cmd, [String? arg]) async {
    if (!Platform.isAndroid) return null;
    try {
      final result = await _methodChannel.invokeMethod<String>(
        'sendCommand',
        {
          'cmd': cmd,
          'arg': arg,
        },
      );
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Pings the daemon over the abstract socket to verify liveness.
  Future<bool> isDaemonRunning() async {
    if (!Platform.isAndroid) return false;
    try {
      final result = await _methodChannel.invokeMethod<bool>('isDaemonRunning');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Subscribes to continuous JSON telemetry lines streamed directly from LocalSocket.
  Stream<String> streamTelemetry({int intervalMs = 2000}) {
    if (!Platform.isAndroid) {
      return const Stream.empty();
    }
    return _eventChannel
        .receiveBroadcastStream({'intervalMs': intervalMs})
        .map((event) => event.toString());
  }

  /// Resets cached availability status (e.g. after daemon restart).
  void resetAvailability() {
    _isChannelSupported = null;
  }
}
