import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/native_ipc_channel.dart';
import 'package:manager/core/platform/daemon_gateway.dart';
import 'package:manager/core/providers/shell_provider.dart';

/// Native LocalSocket channel to `perfmtkd`. Override in tests with a fake.
final nativeIpcProvider = Provider<NativeIpc>((ref) => NativeIpcChannel());

/// Daemon access with IPC-first / shell-fallback semantics.
final daemonGatewayProvider = Provider<DaemonGateway>((ref) {
  return DaemonGateway(
    shell: ref.watch(shellExecutorProvider),
    ipc: ref.watch(nativeIpcProvider),
  );
});
