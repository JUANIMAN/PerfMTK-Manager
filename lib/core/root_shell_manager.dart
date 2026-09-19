import 'dart:async';
import 'dart:convert';
import 'dart:io';

abstract interface class ShellCommandExecutor {
  Future<String> executeCommand(
    String command, {
    Duration timeout = const Duration(seconds: 5),
  });
  Future<void> initialize();
}

/// Long-lived, serialized root shell used by all repositories.
class RootShellManager implements ShellCommandExecutor {
  static final RootShellManager _instance = RootShellManager._internal();
  factory RootShellManager() => _instance;
  RootShellManager._internal();

  Process? _rootShell;
  bool _isActive = false;
  Future<void>? _initialization;
  StreamSubscription<String>? _stdoutSubscription;
  StreamSubscription<String>? _stderrSubscription;

  Future<void> _commandQueue = Future.value();

  final StreamController<String> _lineController =
      StreamController<String>.broadcast();

  /// Starts and verifies the root shell. Concurrent callers share one attempt.
  @override
  Future<void> initialize() async {
    final pendingInitialization = _initialization;
    if (pendingInitialization != null) return pendingInitialization;
    if (_isActive) return;

    final initialization = _startShell();
    _initialization = initialization;
    try {
      await initialization;
    } finally {
      if (identical(_initialization, initialization)) {
        _initialization = null;
      }
    }
  }

  Future<void> _startShell() async {
    try {
      final process = await Process.start('su', []);
      _rootShell = process;

      _stdoutSubscription = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            _lineController.add,
            onError: _lineController.addError,
            onDone: () {
              if (identical(_rootShell, process)) {
                _isActive = false;
                _rootShell = null;
                _lineController.addError(
                  const RootShellException('Root shell exited unexpectedly'),
                );
              }
            },
          );

      _stderrSubscription = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(_lineController.addError);

      _isActive = true;
      final result = await _sendAndCollect(
        'echo "shell_ready"',
        const Duration(seconds: 5),
        restartOnTimeout: false,
      );
      if (result.trim() != 'shell_ready') {
        throw const RootShellException('Shell verification failed');
      }
    } catch (_) {
      await _cleanup();
      rethrow;
    }
  }

  /// Runs one command at a time and throws when it times out or exits non-zero.
  @override
  Future<String> executeCommand(
    String command, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    final result = _commandQueue.then((_) async {
      if (!_isActive) await initialize();
      return _sendAndCollect(command, timeout);
    });

    _commandQueue = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<String> _sendAndCollect(
    String command,
    Duration timeout, {
    bool restartOnTimeout = true,
  }) async {
    final process = _rootShell;
    if (process == null || !_isActive) {
      throw const RootShellException('Shell process is not running');
    }

    final marker = 'CMD_${DateTime.now().microsecondsSinceEpoch}_END';
    final completer = Completer<({int exitCode, List<String> lines})>();
    final output = <String>[];

    late StreamSubscription<String> commandSubscription;
    commandSubscription = _lineController.stream.listen(
      (line) {
        if (!line.startsWith('$marker:')) {
          output.add(line);
          return;
        }

        commandSubscription.cancel();
        final exitCode = int.tryParse(line.substring(marker.length + 1));
        if (exitCode == null) {
          if (!completer.isCompleted) {
            completer.completeError(
              const RootShellException('Invalid shell response'),
            );
          }
          return;
        }

        // The protocol writes a leading newline before its marker so command
        // output that does not end with one can still be parsed safely.
        if (output.isNotEmpty && output.last.isEmpty) output.removeLast();
        if (!completer.isCompleted) {
          completer.complete((
            exitCode: exitCode,
            lines: List<String>.unmodifiable(output),
          ));
        }
      },
      onError: (Object error) {
        commandSubscription.cancel();
        if (!completer.isCompleted) completer.completeError(error);
      },
    );

    try {
      process.stdin.writeln(
        '($command) 2>&1; printf \'\\n$marker:%s\\n\' "\$?"',
      );

      final result = await completer.future.timeout(
        timeout,
        onTimeout: () {
          commandSubscription.cancel();
          throw TimeoutException('Command execution timeout', timeout);
        },
      );

      final commandOutput = result.lines.join('\n');
      if (result.exitCode != 0) {
        final details = commandOutput.trim();
        throw RootShellException(
          details.isEmpty
              ? 'Command failed with exit code ${result.exitCode}'
              : 'Command failed with exit code ${result.exitCode}: $details',
        );
      }

      return commandOutput;
    } catch (error) {
      commandSubscription.cancel();
      if (error is TimeoutException) {
        if (restartOnTimeout) {
          try {
            await restart();
          } catch (_) {
            // Keep the timeout as the actionable error for the caller.
          }
        }
        throw RootShellException('Command timeout: $command');
      }
      if (error is RootShellException) rethrow;
      throw RootShellException('Command execution failed: $error');
    }
  }

  Future<bool> hasRootAccess() async {
    try {
      await initialize();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> dispose() => _cleanup();

  Future<void> restart() async {
    await _cleanup();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await initialize();
  }

  Future<void> _cleanup() async {
    _isActive = false;

    await _stdoutSubscription?.cancel();
    await _stderrSubscription?.cancel();
    _stdoutSubscription = null;
    _stderrSubscription = null;

    final process = _rootShell;
    _rootShell = null;
    try {
      process?.stdin.writeln('exit');
      await process?.stdin.close();
    } catch (_) {}

    process?.kill();
  }
}

class RootShellException implements Exception {
  final String message;
  const RootShellException(this.message);

  @override
  String toString() => 'RootShellException: $message';
}
