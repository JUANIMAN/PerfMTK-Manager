import 'dart:io';
import 'dart:async';
import 'dart:convert';

/// Gestor de shell root — singleton
class RootShellManager {
  static final RootShellManager _instance = RootShellManager._internal();
  factory RootShellManager() => _instance;
  RootShellManager._internal();

  Process? _rootShell;
  bool _isActive = false;
  Completer<void>? _initCompleter;

  // Cola para serializar comandos
  Future<void> _commandQueue = Future.value();

  // Stream broadcast del stdout de la shell
  final StreamController<String> _lineController =
  StreamController<String>.broadcast();

  /// Inicia la shell root
  Future<void> initialize() async {
    if (_isActive) return;

    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();

    try {
      _rootShell = await Process.start('su', []);

      _rootShell!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        _lineController.add,
        onError: _lineController.addError,
        onDone: () {
          _isActive = false;
          _rootShell = null;
        },
      );

      _rootShell!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => _lineController.addError(line));

      _isActive = true;

      // Verificar que la shell responde
      final result = await _sendAndCollect(
        'echo "shell_ready"',
        const Duration(seconds: 5),
      );
      if (!result.contains('shell_ready')) {
        throw RootShellException('Shell verification failed');
      }

      _initCompleter!.complete();
    } catch (e) {
      await _cleanup();
      _initCompleter!.completeError(e);
      rethrow;
    } finally {
      _initCompleter = null;
    }
  }

  /// Ejecutar comando en la shell root y esperar la respuesta
  ///
  /// [command] - El comando a ejecutar
  /// [timeout] - Tiempo máximo de espera (por defecto 5 segundos)
  ///
  /// Lanza [RootShellException] si el comando falla o timeout
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

  Future<String> _sendAndCollect(String command, Duration timeout) async {
    if (_rootShell == null) {
      throw RootShellException('Shell process is not running');
    }

    final marker = 'CMD_${DateTime.now().microsecondsSinceEpoch}_END';
    final completer = Completer<List<String>>();
    final output = <String>[];

    late StreamSubscription<String> sub;
    sub = _lineController.stream.listen(
          (line) {
        if (line.contains(marker)) {
          sub.cancel();
          if (!completer.isCompleted) completer.complete(List.unmodifiable(output));
        } else {
          output.add(line);
        }
      },
      onError: (Object error) {
        sub.cancel();
        if (!completer.isCompleted) completer.completeError(error);
      },
    );

    try {
      _rootShell!.stdin.writeln('$command; echo "$marker"');

      final lines = await completer.future.timeout(
        timeout,
        onTimeout: () {
          sub.cancel();
          throw TimeoutException('Command execution timeout', timeout);
        },
      );

      return lines.join('\n');
    } catch (e) {
      sub.cancel();
      if (e is TimeoutException) {
        // La shell puede estar en estado inconsistente — reiniciar.
        await restart();
        throw RootShellException('Command timeout: $command');
      }
      throw RootShellException('Command execution failed: $e');
    }
  }

  /// Devuelve `true` si la shell root está disponible.
  Future<bool> hasRootAccess() async {
    try {
      await initialize();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Cierra la shell y libera recursos sin cerrar el broadcast controller,
  Future<void> dispose() async {
    await _cleanup();
  }

  /// Reinicia la shell root.
  Future<void> restart() async {
    await _cleanup();
    await Future.delayed(const Duration(milliseconds: 100));
    await initialize();
  }

  Future<void> _cleanup() async {
    _isActive = false;

    try {
      _rootShell?.stdin.writeln('exit');
      await _rootShell?.stdin.close();
    } catch (_) {}

    _rootShell?.kill();
    _rootShell = null;
  }
}

/// Excepción para errores de shell root.
class RootShellException implements Exception {
  final String message;
  const RootShellException(this.message);

  @override
  String toString() => 'RootShellException: $message';
}