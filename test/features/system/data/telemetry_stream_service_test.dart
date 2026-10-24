import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manager/features/system/data/models/profile.dart';
import 'package:manager/features/system/data/models/system_state.dart';
import 'package:manager/features/system/data/telemetry_stream_service.dart';
import 'package:manager/features/system/data/shm_telemetry_decoder.dart';
import '../../../support/fakes.dart';

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
        ipcChannel: FakeNativeIpc(),
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
        ipcChannel: FakeNativeIpc(),
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
        ipcChannel: FakeNativeIpc(),
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
        ipcChannel: FakeNativeIpc(),
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

    test('ShmTelemetryDecoder decodes 2784-byte PerfMTKSharedTelemetry binary snapshot', () {
      final bytes = Uint8List(ShmLayout.structSize);
      final bd = ByteData.sublistView(bytes);

      void writeStr(int offset, int maxLen, String val) {
        final encoded = utf8.encode(val);
        final len = encoded.length < maxLen - 1 ? encoded.length : maxLen - 1;
        bytes.setRange(offset, offset + len, encoded);
        bytes[offset + len] = 0;
      }

      bd.setUint32(0, ShmLayout.magic, Endian.host);
      bd.setUint32(4, ShmLayout.version, Endian.host);
      bd.setUint32(8, 42, Endian.host); // even seq
      bd.setUint32(12, (1 << 0) | (1 << 1) | (1 << 2) | (1 << 4) | (1 << 5), Endian.host);
      bd.setUint64(16, 123456789, Endian.host);
      bd.setInt32(24, 12, Endian.host);     // drivers_active
      bd.setInt32(28, 120, Endian.host);    // display_fps
      bd.setInt32(32, 60, Endian.host);     // game_fps
      bd.setInt32(36, 31, Endian.host);     // battery_temp_c
      bd.setInt32(40, 38500, Endian.host);  // soc_temp_mdeg -> 38.5C
      bd.setInt32(44, 85, Endian.host);     // battery_capacity_pct
      bd.setInt32(48, 120, Endian.host);    // cycle_count
      bd.setInt32(52, 98, Endian.host);     // soh_pct
      bd.setInt32(56, 4900, Endian.host);   // charge_full_mah
      bd.setInt32(60, 5000, Endian.host);   // charge_design_mah
      bd.setInt32(64, 4250, Endian.host);   // charge_counter_mah
      bd.setInt32(68, 1980, Endian.host);   // charge_current_now_ma
      bd.setInt32(72, 4120, Endian.host);   // charge_voltage_now_mv
      bd.setInt32(76, 8158, Endian.host);   // charge_power_mw -> 8.158W
      bd.setInt32(80, 2000, Endian.host);   // charge_current_limit_ma
      bd.setInt32(84, 1500, Endian.host);   // gentle_charge_ma
      bd.setInt32(88, 80, Endian.host);     // battery_care_limit_pct
      bd.setInt32(92, 1, Endian.host);      // pinned_threads_count

      writeStr(96, 16, '17.2');
      writeStr(112, 32, 'performance');
      writeStr(144, 128, 'com.miHoYo.GenshinImpact');
      writeStr(272, 48, 'LSPosed Hook (Push)');
      writeStr(320, 32, 'mt6897');
      writeStr(352, 32, '4+3+1');
      writeStr(384, 32, 'gpufreqv2');
      writeStr(416, 128, 'P0: 2200MHz | P1: 3000MHz | P2: 3350MHz');
      writeStr(544, 32, '1100MHz');
      writeStr(576, 32, '4266MHz');
      writeStr(608, 64, 'min: 45.00 | max: max');
      writeStr(672, 32, 'bypass');
      writeStr(704, 32, 'Charging');

      // Pinned thread 0 at offset 736
      bd.setInt32(736, 4567, Endian.host);
      writeStr(736 + 4, 28, 'UnityMain');
      writeStr(736 + 32, 32, 'Prime Core (CPU7)');

      final state = ShmTelemetryDecoder.decode(bytes, bd);
      expect(state, isNotNull);
      expect(state!.version, '17.2');
      expect(state.currentProfile, ProfileType.performance);
      expect(state.thermalState, ThermalState.enabled);
      expect(state.currentApp, 'com.miHoYo.GenshinImpact');
      expect(state.screenOn, true);
      expect(state.chargeBypass, true);
      expect(state.batteryCareEnabled, true);
      expect(state.backgroundJailed, true);
      expect(state.driversActive, 12);
      expect(state.displayFps, 120);
      expect(state.gameFps, 60);
      expect(state.batteryTempC, 31);
      expect(state.socTempC, closeTo(38.5, 0.01));
      expect(state.chargePowerW, closeTo(8.158, 0.001));
      expect(state.pinnedThreads.length, 1);
      expect(state.pinnedThreads.first['tid'], 4567);
      expect(state.pinnedThreads.first['name'], 'UnityMain');
      expect(state.pinnedThreads.first['role'], 'Prime Core (CPU7)');
    });
  });
}
