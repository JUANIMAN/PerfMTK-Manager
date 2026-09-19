import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/root_shell_manager.dart';

/// Riverpod provider for the root shell command executor.
/// Allows mock/fake implementations to be injected in unit tests.
final shellExecutorProvider = Provider<ShellCommandExecutor>((ref) {
  return RootShellManager();
});
