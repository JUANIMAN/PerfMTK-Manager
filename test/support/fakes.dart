import 'dart:async';

import 'package:manager/core/errors/app_exception.dart';
import 'package:manager/core/native_ipc_channel.dart';
import 'package:manager/core/platform/daemon_gateway.dart';
import 'package:manager/core/root_shell_manager.dart';

/// Scriptable [NativeIpc]: map a command to a reply (or null = unavailable).
class FakeNativeIpc implements NativeIpc {
  final Map<String, String?> replies;
  final List<String> calls = [];

  FakeNativeIpc([Map<String, String?>? replies]) : replies = replies ?? {};

  @override
  Future<String?> sendCommand(String cmd, [String? arg]) async {
    calls.add(arg == null ? cmd : '$cmd $arg');
    return replies[cmd];
  }

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> isDaemonRunning() async => false;

  @override
  Future<int?> subscribeShm({int intervalMs = 1000}) async => null;

  @override
  Future<void> unsubscribeShm() async {}

  @override
  Stream<String> streamTelemetry({int intervalMs = 2000}) =>
      const Stream.empty();
}

/// Scriptable [ShellCommandExecutor]. [handler] returns the output for a
/// command or throws; by default every command succeeds with empty output.
class FakeShell implements ShellCommandExecutor {
  final String Function(String command)? handler;
  final List<String> commands = [];

  FakeShell([this.handler]);

  @override
  Future<void> initialize() async {}

  @override
  Future<String> executeCommand(
    String command, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    commands.add(command);
    return handler?.call(command) ?? '';
  }
}

/// Shell that always fails, as if root were unavailable.
class FailingShell extends FakeShell {
  FailingShell() : super();

  @override
  Future<String> executeCommand(
    String command, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    commands.add(command);
    throw const RootShellException('no root');
  }
}

DaemonGateway fakeGateway({FakeNativeIpc? ipc, ShellCommandExecutor? shell}) =>
    DaemonGateway(shell: shell ?? FakeShell(), ipc: ipc ?? FakeNativeIpc());
