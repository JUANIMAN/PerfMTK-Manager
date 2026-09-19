import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:manager/core/native_ipc_channel.dart';
import 'package:manager/data/models/system_state.dart';

typedef ProcessStarter = Future<Process> Function(String executable, List<String> arguments);

/// Persistent root telemetry stream service.
///
/// Subscribes to the native LocalSocket stream from `@perfmtkd_ctrl` (zero-fork)
/// or spawns a fallback `perfmtk --stream-json <interval>` process.
/// Automatically pauses process execution when the app enters background or screen locks,
/// and resumes when the app returns to foreground.
class TelemetryStreamService with WidgetsBindingObserver {
  final int intervalMs;
  final ProcessStarter? _processStarter;
  final NativeIpcChannel _ipcChannel;

  Process? _process;
  StreamSubscription<String>? _stdoutSubscription;
  StreamSubscription<String>? _stderrSubscription;
  StreamSubscription<String>? _nativeStreamSubscription;
  Timer? _reconnectTimer;

  bool _isDisposed = false;
  bool _isPaused = false;
  bool _isStarting = false;

  SystemState? _latestState;
  final StreamController<SystemState> _controller =
      StreamController<SystemState>.broadcast();

  TelemetryStreamService({
    this.intervalMs = 2000,
    ProcessStarter? processStarter,
    NativeIpcChannel? ipcChannel,
  })  : _processStarter = processStarter,
        _ipcChannel = ipcChannel ?? NativeIpcChannel();

  /// Stream of live system states emitted continuously by the native daemon.
  Stream<SystemState> get stream => _controller.stream;

  /// Latest parsed system state, or null if no packet received yet.
  SystemState? get latestState => _latestState;

  /// Whether the streaming process is currently running.
  bool get isRunning =>
      (_process != null || _nativeStreamSubscription != null) && !_isPaused;

  /// Initializes the service, registers app lifecycle observer, and starts streaming.
  Future<void> start() async {
    if (_isDisposed) return;
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {
      // In non-Flutter test environments, WidgetsBinding might not be bound.
    }
    _isPaused = false;
    await _startStream();
  }

  Future<void> _startStream() async {
    if (_isDisposed || _isPaused || _isStarting || isRunning) return;
    _isStarting = true;

    try {
      if (_processStarter == null && Platform.isAndroid) {
        final available = await _ipcChannel.isAvailable();
        if (available) {
          _nativeStreamSubscription = _ipcChannel
              .streamTelemetry(intervalMs: intervalMs)
              .listen(
                _handleLine,
                onError: (_) {
                  _nativeStreamSubscription?.cancel();
                  _nativeStreamSubscription = null;
                  _scheduleReconnect();
                },
                onDone: () {
                  _nativeStreamSubscription = null;
                  _scheduleReconnect();
                },
                cancelOnError: false,
              );
          return;
        }
      }

      await _startStreamProcess();
    } catch (e) {
      _scheduleReconnect();
    } finally {
      _isStarting = false;
    }
  }

  Future<void> _startStreamProcess() async {
    if (_isDisposed || _isPaused || _process != null) return;

    try {
      final starter = _processStarter ?? Process.start;
      final process = await starter(
        'su',
        ['-c', 'perfmtk --stream-json $intervalMs'],
      );

      if (_isDisposed || _isPaused) {
        process.kill();
        return;
      }

      _process = process;

      _stdoutSubscription = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            _handleLine,
            onError: (err) {
              // Log or emit without crashing the controller
            },
            onDone: _handleProcessDone,
            cancelOnError: false,
          );

      _stderrSubscription = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (_) {},
            onError: (_) {},
            cancelOnError: false,
          );
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _handleLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return;

    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return;

    try {
      final jsonChunk = trimmed.substring(start, end + 1);
      final decoded = jsonDecode(jsonChunk) as Map<String, dynamic>;
      final state = SystemState.fromJson(decoded);
      _latestState = state;
      if (!_controller.isClosed) {
        _controller.add(state);
      }
    } catch (_) {
      // Ignore malformed partial lines
    }
  }

  void _handleProcessDone() {
    _stopProcess();
    if (!_isDisposed && !_isPaused) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_isDisposed || _isPaused) return;

    _reconnectTimer = Timer(const Duration(seconds: 2), () {
      if (!_isDisposed && !_isPaused) {
        _startStream();
      }
    });
  }

  void _stopProcess() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _nativeStreamSubscription?.cancel();
    _nativeStreamSubscription = null;

    _stdoutSubscription?.cancel();
    _stdoutSubscription = null;

    _stderrSubscription?.cancel();
    _stderrSubscription = null;

    final p = _process;
    _process = null;
    if (p != null) {
      try {
        p.kill();
      } catch (_) {}
    }
  }

  /// Pauses the stream and closes background resources (e.g. app in background).
  void pause() {
    if (_isPaused) return;
    _isPaused = true;
    _stopProcess();
  }

  /// Resumes the stream and establishes connection if not running.
  Future<void> resume() async {
    if (!_isPaused && isRunning) return;
    _isPaused = false;
    await _startStream();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      resume();
    } else if (state == AppLifecycleState.paused ||
               state == AppLifecycleState.detached ||
               state == AppLifecycleState.hidden) {
      pause();
    }
  }

  /// Disposes resources, subscriptions, and observer.
  void dispose() {
    _isDisposed = true;
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
    _stopProcess();
    _controller.close();
  }
}
