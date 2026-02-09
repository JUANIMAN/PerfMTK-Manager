import 'dart:io';
import 'dart:async';
import 'dart:convert';

/// Gestor de shell root
class RootShellManager {
  static final RootShellManager _instance = RootShellManager._internal();
  factory RootShellManager() => _instance;
  RootShellManager._internal();

  Process? _rootShell;
  final _responseController = StreamController<String>.broadcast();
  bool _isActive = false;
  bool _isInitializing = false;

  /// Inicializa la shell si no está activa
  Future<void> initialize() async {
    if (_isActive) return;
    if (_isInitializing) {
      // Esperar a que termine la inicialización en curso
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return;
    }

    _isInitializing = true;

    try {
      _rootShell = await Process.start('su', []);

      _rootShell!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => _responseController.add(line));

      _rootShell!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => _responseController.addError(line));

      _isActive = true;

      // Verificar que la shell funciona
      final result = await executeCommand('echo "shell_ready"');
      if (!result.contains('shell_ready')) {
        throw RootShellException('Shell verification failed');
      }
    } catch (e) {
      await dispose();
      throw RootShellException('Failed to initialize root shell: $e');
    } finally {
      _isInitializing = false;
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
      }) async {
    if (!_isActive) await initialize();

    final marker = 'CMD_${DateTime.now().millisecondsSinceEpoch}_END';
    final completer = Completer<List<String>>();
    final output = <String>[];

    late StreamSubscription subscription;
    subscription = _responseController.stream.listen(
          (line) {
        if (line.contains(marker)) {
          subscription.cancel();
          completer.complete(output);
        } else {
          output.add(line);
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          subscription.cancel();
          completer.completeError(error);
        }
      },
    );

    try {
      // Enviar comando con marcador de fin
      _rootShell!.stdin.writeln('$command && echo "$marker"');

      final result = await completer.future.timeout(
        timeout,
        onTimeout: () {
          subscription.cancel();
          throw TimeoutException('Command execution timeout', timeout);
        },
      );

      return result.join('\n');
    } catch (e) {
      subscription.cancel();
      if (e is TimeoutException) {
        throw RootShellException('Command timeout: $command');
      }
      throw RootShellException('Command execution failed: $e');
    }
  }

  /// Verifica si hay acceso root disponible
  Future<bool> hasRootAccess() async {
    try {
      await initialize();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cierra la shell root y libera recursos
  Future<void> dispose() async {
    _isActive = false;

    try {
      _rootShell?.stdin.writeln('exit');
      await _rootShell?.stdin.close();
    } catch (e) {
      // Ignorar errores al cerrar
    }

    _rootShell?.kill();
    _rootShell = null;
  }

  /// Reinicia la shell root
  Future<void> restart() async {
    await dispose();
    await Future.delayed(const Duration(milliseconds: 100));
    await initialize();
  }
}

/// Excepción para errores de shell root
class RootShellException implements Exception {
  final String message;
  RootShellException(this.message);

  @override
  String toString() => 'RootShellException: $message';
}