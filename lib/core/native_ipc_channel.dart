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
  /// Only caches positive availability so transient boot delays do not lock out native IPC.
  Future<bool> isAvailable() async {
    if (!Platform.isAndroid) return false;
    if (_isChannelSupported == true) return true;

    try {
      final running = await isDaemonRunning();
      if (running) {
        _isChannelSupported = true;
      }
      return running;
    } catch (_) {
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

  /// Subscribes to Zero-Copy Shared Memory telemetry (`memfd` + `SCM_RIGHTS`).
  /// Returns the read-only `mmap` virtual memory address in this process, or null if unsupported.
  Future<int?> subscribeShm({int intervalMs = 1000}) async {
    if (!Platform.isAndroid) return null;
    try {
      final addr = await _methodChannel.invokeMethod<int>(
        'subscribeShm',
        {'intervalMs': intervalMs},
      );
      if (addr != null && addr != 0) {
        return addr;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Releases the Zero-Copy Shared Memory liveness lease socket and unmaps the region.
  Future<void> unsubscribeShm() async {
    if (!Platform.isAndroid) return;
    try {
      await _methodChannel.invokeMethod<bool>('unsubscribeShm');
    } catch (_) {}
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
