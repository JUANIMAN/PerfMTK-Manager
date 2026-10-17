import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:manager/core/logging/app_logger.dart';

/// Contract for talking to the `perfmtkd` daemon without forking `su`.
/// Implemented by [NativeIpcChannel]; faked in tests.
abstract interface class NativeIpc {
  Future<bool> isAvailable();
  Future<String?> sendCommand(String cmd, [String? arg]);
  Future<bool> isDaemonRunning();
  Future<int?> subscribeShm({int intervalMs});
  Future<void> unsubscribeShm();
  Stream<String> streamTelemetry({int intervalMs});
}

/// Direct Native IPC channel communicating with `@perfmtkd_ctrl` abstract socket
/// via Android LocalSocket, bypassing `su` process forks.
class NativeIpcChannel implements NativeIpc {
  static const String _tag = 'NativeIpc';
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
  @override
  Future<bool> isAvailable() async {
    if (!Platform.isAndroid) return false;
    if (_isChannelSupported == true) return true;

    final running = await isDaemonRunning();
    if (running) {
      _isChannelSupported = true;
    }
    return running;
  }

  /// Sends a raw command to the native daemon via abstract LocalSocket.
  /// Returns the string response or null if the socket or platform call fails.
  @override
  Future<String?> sendCommand(String cmd, [String? arg]) async {
    if (!Platform.isAndroid) return null;
    try {
      return await _methodChannel.invokeMethod<String>(
        'sendCommand',
        {'cmd': cmd, 'arg': arg},
      );
    } on Exception catch (e) {
      AppLogger.debug(_tag, 'sendCommand($cmd) failed: $e');
      return null;
    }
  }

  /// Pings the daemon over the abstract socket to verify liveness.
  @override
  Future<bool> isDaemonRunning() async {
    if (!Platform.isAndroid) return false;
    try {
      final result = await _methodChannel.invokeMethod<bool>('isDaemonRunning');
      return result ?? false;
    } on Exception catch (e) {
      AppLogger.debug(_tag, 'isDaemonRunning failed: $e');
      return false;
    }
  }

  /// Subscribes to Zero-Copy Shared Memory telemetry (`memfd` + `SCM_RIGHTS`).
  /// Returns the read-only `mmap` virtual memory address in this process, or null if unsupported.
  @override
  Future<int?> subscribeShm({int intervalMs = 1000}) async {
    if (!Platform.isAndroid) return null;
    try {
      final addr = await _methodChannel.invokeMethod<int>(
        'subscribeShm',
        {'intervalMs': intervalMs},
      );
      return (addr != null && addr != 0) ? addr : null;
    } on Exception catch (e) {
      AppLogger.debug(_tag, 'subscribeShm failed: $e');
      return null;
    }
  }

  /// Releases the Zero-Copy Shared Memory liveness lease socket and unmaps the region.
  @override
  Future<void> unsubscribeShm() async {
    if (!Platform.isAndroid) return;
    try {
      await _methodChannel.invokeMethod<bool>('unsubscribeShm');
    } on Exception catch (e) {
      AppLogger.debug(_tag, 'unsubscribeShm failed: $e');
    }
  }

  /// Subscribes to continuous JSON telemetry lines streamed directly from LocalSocket.
  @override
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
