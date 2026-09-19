import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/data/services/telemetry_stream_service.dart';

class FakeProcess implements Process {
  final StreamController<List<int>> stdoutController = StreamController<List<int>>();
  final StreamController<List<int>> stderrController = StreamController<List<int>>();
  final Completer<int> exitCompleter = Completer<int>();
  bool killed = false;

  @override
  Stream<List<int>> get stdout => stdoutController.stream;

  @override
  Stream<List<int>> get stderr => stderrController.stream;

  @override
  IOSink get stdin => throw UnimplementedError();

  @override
  int get pid => 1234;

  @override
  Future<int> get exitCode => exitCompleter.future;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killed = true;
    if (!exitCompleter.isCompleted) {
      exitCompleter.complete(0);
    }
    stdoutController.close();
    stderrController.close();
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelemetryStreamService', () {
    test('starts process and emits parsed SystemState from stdout lines', () async {
      late FakeProcess fakeProcess;
      final service = TelemetryStreamService(
        intervalMs: 1000,
        processStarter: (exe, args) async {
          fakeProcess = FakeProcess();
          return fakeProcess;
        },
      );

      await service.start();
      expect(service.isRunning, true);

      final emissions = <SystemState>[];
      final sub = service.stream.listen(emissions.add);

      const jsonLine =
          '{"version":"16.1","active_profile":"performance","thermal_state":"enabled","temperatures":{"soc_c":45.0,"battery_c":32}}\n';
      fakeProcess.stdoutController.add(utf8.encode(jsonLine));

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emissions.length, 1);
      expect(emissions.first.currentProfile, ProfileType.performance);
      expect(emissions.first.thermalState, ThermalState.enabled);
      expect(emissions.first.socTempC, 45.0);
      expect(emissions.first.batteryTempC, 32);
      expect(service.latestState, emissions.first);

      await sub.cancel();
      service.dispose();
      expect(fakeProcess.killed, true);
    });

    test('pause kills the process and resume starts a new one', () async {
      final createdProcesses = <FakeProcess>[];
      final service = TelemetryStreamService(
        intervalMs: 1000,
        processStarter: (exe, args) async {
          final p = FakeProcess();
          createdProcesses.add(p);
          return p;
        },
      );

      await service.start();
      expect(createdProcesses.length, 1);
      expect(service.isRunning, true);

      service.pause();
      expect(service.isRunning, false);
      expect(createdProcesses.first.killed, true);

      await service.resume();
      expect(createdProcesses.length, 2);
      expect(service.isRunning, true);

      service.dispose();
      expect(createdProcesses[1].killed, true);
    });

    test('ignores malformed lines without throwing', () async {
      late FakeProcess fakeProcess;
      final service = TelemetryStreamService(
        intervalMs: 1000,
        processStarter: (exe, args) async {
          fakeProcess = FakeProcess();
          return fakeProcess;
        },
      );

      await service.start();
      final emissions = <SystemState>[];
      final sub = service.stream.listen(emissions.add);

      fakeProcess.stdoutController.add(utf8.encode('Random garbage\n'));
      fakeProcess.stdoutController.add(utf8.encode('{"incomplete": \n'));
      fakeProcess.stdoutController.add(utf8.encode('{"active_profile":"powersave"}\n'));

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emissions.length, 1);
      expect(emissions.first.currentProfile, ProfileType.powersave);

      await sub.cancel();
      service.dispose();
    });

    test('didChangeAppLifecycleState pauses on background and resumes on foreground', () async {
      final createdProcesses = <FakeProcess>[];
      final service = TelemetryStreamService(
        intervalMs: 1000,
        processStarter: (exe, args) async {
          final p = FakeProcess();
          createdProcesses.add(p);
          return p;
        },
      );

      await service.start();
      expect(service.isRunning, true);

      service.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(service.isRunning, false);
      expect(createdProcesses.first.killed, true);

      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(service.isRunning, true);
      expect(createdProcesses.length, 2);

      service.dispose();
    });
  });
}
