import 'dart:convert';

import 'package:manager/core/errors/app_exception.dart';
import 'package:manager/core/logging/app_logger.dart';
import 'package:manager/core/native_ipc_channel.dart';
import 'package:manager/core/root_shell_manager.dart';

/// Single entry point for talking to the PerfMTK daemon.
///
/// Every operation prefers the zero-fork LocalSocket IPC and falls back to the
/// root shell/CLI when the daemon socket is unavailable or rejects the call.
class DaemonGateway {
  static const String _tag = 'DaemonGateway';

  final ShellCommandExecutor _shell;
  final NativeIpc _ipc;

  const DaemonGateway({
    required ShellCommandExecutor shell,
    required NativeIpc ipc,
  }) : _shell = shell,
       _ipc = ipc;

  /// Runs [command] in the persistent root shell. Throws [RootShellException].
  Future<String> shell(
    String command, {
    Duration timeout = const Duration(seconds: 5),
  }) => _shell.executeCommand(command, timeout: timeout);

  /// Ensures the root shell can start. Throws when root is unavailable.
  Future<void> ensureRoot() => _shell.initialize();

  /// Raw IPC call. Returns null when the socket/platform call fails.
  Future<String?> ipc(String cmd, [String? arg]) => _ipc.sendCommand(cmd, arg);

  /// Sends [cmd] over IPC; when the reply is missing or does not start with
  /// [okPrefix], executes [shellFallback] instead (throws on failure).
  Future<void> command(
    String cmd, {
    String? arg,
    required String shellFallback,
    Duration timeout = const Duration(seconds: 5),
    String okPrefix = 'OK',
  }) async {
    final resp = await _ipc.sendCommand(cmd, arg);
    if (resp != null && resp.trim().startsWith(okPrefix)) return;
    AppLogger.debug(_tag, '$cmd via IPC not acknowledged, using shell');
    await _shell.executeCommand(shellFallback, timeout: timeout);
  }

  /// IPC call whose reply is a JSON object; null when unavailable or invalid.
  Future<Map<String, dynamic>?> ipcJson(String cmd, [String? arg]) async {
    final raw = await _ipc.sendCommand(cmd, arg);
    if (raw == null) return null;
    return extractJsonObject(raw);
  }

  /// Shell call whose output contains a JSON object (CLI banners are skipped).
  Future<Map<String, dynamic>?> shellJson(
    String command, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final raw = await _shell.executeCommand(command, timeout: timeout);
      return extractJsonObject(raw);
    } on RootShellException catch (e) {
      AppLogger.debug(_tag, 'shellJson failed: $e');
      return null;
    }
  }

  /// Extracts the outermost `{…}` from [raw] (tolerates ANSI/banner noise).
  static Map<String, dynamic>? extractJsonObject(String raw) {
    final trimmed = raw.trim();
    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    try {
      final decoded = jsonDecode(trimmed.substring(start, end + 1));
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException catch (e) {
      AppLogger.warn(_tag, 'invalid JSON payload', e);
      return null;
    }
  }
}
