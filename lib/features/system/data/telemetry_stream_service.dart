import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:manager/core/native_ipc_channel.dart';
import 'package:manager/features/system/data/models/system_state.dart';
import 'package:manager/features/system/data/shm_telemetry_decoder.dart';

typedef ProcessStarter = Future<Process> Function(String executable, List<String> arguments);

/// Persistent root telemetry stream service.
///
/// Tier 1 (Primary): Maps `perfmtkd` anonymous `memfd` shared memory (`SUBSCRIBE_SHM` + `SCM_RIGHTS`)
/// and reads `PerfMTKSharedTelemetry` directly from RAM via `dart:ffi` + Seqlock with zero JSON parsing
/// and zero socket traffic.
/// Tier 2 (Fallback): Subscribes to the native LocalSocket JSON stream from `@perfmtkd_ctrl`.
/// Tier 3 (Fallback): Spawns `perfmtk --stream-json <interval>`.
/// Automatically releases the liveness lease when the app enters background or screen locks.
class TelemetryStreamService with WidgetsBindingObserver {
  final int intervalMs;
  final ProcessStarter? _processStarter;
  final NativeIpc _ipcChannel;

  Process? _process;
  StreamSubscription<String>? _stdoutSubscription;
  StreamSubscription<String>? _stderrSubscription;
  StreamSubscription<String>? _nativeStreamSubscription;
  Timer? _shmPollTimer;
  Timer? _reconnectTimer;

  int _shmAddress = 0;
  int _lastShmSeq = 0;
  int _staleShmTicks = 0;
  final Uint8List _shmScratchBuffer = Uint8List(ShmLayout.structSize);
  late final ByteData _shmScratchView = ByteData.sublistView(_shmScratchBuffer);

  bool _isDisposed = false;
  bool _isPaused = false;
  bool _isStarting = false;

  SystemState? _latestState;
  final StreamController<SystemState> _controller =
      StreamController<SystemState>.broadcast();

  TelemetryStreamService({
    this.intervalMs = 1000,
    ProcessStarter? processStarter,
    required NativeIpc ipcChannel,
  })  : _processStarter = processStarter,
        _ipcChannel = ipcChannel;

  /// Stream of live system states emitted continuously by the native daemon.
  Stream<SystemState> get stream => _controller.stream;

  /// Latest parsed system state, or null if no packet received yet.
  SystemState? get latestState => _latestState;

  /// Whether Zero-Copy Shared Memory mode is currently active.
  bool get isZeroCopyShmActive => _shmAddress != 0 && _shmPollTimer != null;

  /// Whether the streaming service is currently running.
  bool get isRunning =>
      (_shmPollTimer != null ||
          _process != null ||
          _nativeStreamSubscription != null) &&
      !_isPaused;

  /// Initializes the service, registers app lifecycle observer, and starts streaming.
  Future<void> start() async {
    if (_isDisposed) return;
    try {
      WidgetsBinding.instance.addObserver(this);
    } on Object catch (_) {
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
          // Tier 1: Zero-Copy Shared Memory (memfd + SCM_RIGHTS + dart:ffi Seqlock)
          final shmPollMs = intervalMs.clamp(250, 1000);
          final addr = await _ipcChannel.subscribeShm(intervalMs: shmPollMs);
          if (addr != null && addr != 0 && !_isDisposed && !_isPaused) {
            _shmAddress = addr;
            _lastShmSeq = 0;
            _staleShmTicks = 0;
            _pollShmSnapshot();
            _shmPollTimer = Timer.periodic(
              Duration(milliseconds: shmPollMs),
              (_) => _pollShmSnapshot(),
            );
            return;
          }

          // Tier 2: Legacy LocalSocket JSON stream fallback
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

      // Tier 3: Root CLI process fallback
      await _startStreamProcess();
    } on Object {
      _scheduleReconnect();
    } finally {
      _isStarting = false;
    }
  }

  void _pollShmSnapshot() {
    final addr = _shmAddress;
    if (addr == 0 || _isDisposed || _isPaused) return;

    try {
      final ptr = ffi.Pointer<ffi.Uint8>.fromAddress(addr);
      final liveBytes = ptr.asTypedList(ShmLayout.structSize);
      final liveView = ByteData.sublistView(liveBytes);

      // Lockless Seqlock read retry loop (up to 3 attempts if writer is mid-transaction)
      for (int attempt = 0; attempt < 3; attempt++) {
        final seq1 = liveView.getUint32(ShmLayout.seqOffset, Endian.host);
        if (seq1 == 0 || (seq1 & 1) != 0) {
          continue; // Writer is currently updating SHM (seq is odd)
        }

        if (seq1 == _lastShmSeq && _latestState != null) {
          _staleShmTicks++;
          // If SHM sequence hasn't advanced for >6 seconds, daemon may have restarted
          final maxStaleTicks = (6000 ~/ intervalMs.clamp(250, 1000)).clamp(6, 24);
          if (_staleShmTicks > maxStaleTicks) {
            _stopProcess();
            _scheduleReconnect();
          }
          return;
        }

        _shmScratchBuffer.setRange(0, ShmLayout.structSize, liveBytes);
        final seq2 = liveView.getUint32(ShmLayout.seqOffset, Endian.host);

        if (seq1 == seq2) {
          final state = ShmTelemetryDecoder.decode(
            _shmScratchBuffer,
            _shmScratchView,
          );
          if (state != null) {
            _lastShmSeq = seq1;
            _staleShmTicks = 0;
            _latestState = state;
            if (!_controller.isClosed) {
              _controller.add(state);
            }
            return;
          }
        }
      }
    } on Object catch (_) {
      _stopProcess();
      _scheduleReconnect();
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
    } on Object {
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
    } on Object catch (_) {
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

    _shmPollTimer?.cancel();
    _shmPollTimer = null;
    if (_shmAddress != 0) {
      _shmAddress = 0;
      _lastShmSeq = 0;
      _staleShmTicks = 0;
      unawaited(_ipcChannel.unsubscribeShm());
    }

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
      } on Object catch (_) {}
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
    } on Object catch (_) {}
    _stopProcess();
    _controller.close();
  }
}
