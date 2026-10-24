import 'package:flutter_test/flutter_test.dart';
import 'package:manager/core/errors/app_exception.dart';
import 'package:manager/features/system/data/models/profile.dart';
import 'package:manager/features/system/data/models/system_state.dart';
import 'package:manager/features/system/data/system_repository.dart';

import '../../../support/fakes.dart';

String _props(String command) {
  if (command.contains('current_profile')) return 'performance\n';
  if (command.contains('thermal_state')) return 'disabled\n';
  return '';
}

void main() {
  group('SystemRepositoryImpl.getSystemState', () {
    test('prefers the IPC status payload', () async {
      final repo = SystemRepositoryImpl(
        gateway: fakeGateway(
          ipc: FakeNativeIpc({
            'STATUS_JSON': '{"active_profile":"powersave","version":"1.0"}',
          }),
          shell: FakeShell(_props),
        ),
      );

      final state = await repo.getSystemState();

      expect(state.currentProfile, ProfileType.powersave);
      expect(state.version, '1.0');
      expect(state.thermalState, ThermalState.disabled);
    });

    test('uses the CLI payload when IPC is unavailable', () async {
      final repo = SystemRepositoryImpl(
        gateway: fakeGateway(
          shell: FakeShell(
            (c) => c == 'perfmtk -s --json'
                ? 'banner\n{"active_profile":"balanced"}'
                : _props(c),
          ),
        ),
      );

      expect((await repo.getSystemState()).currentProfile, ProfileType.balanced);
    });

    test('falls back to system properties when no JSON is available', () async {
      final repo = SystemRepositoryImpl(
        gateway: fakeGateway(shell: FakeShell(_props)),
      );

      expect(
        (await repo.getSystemState()).currentProfile,
        ProfileType.performance,
      );
    });

    test('skips an IPC payload with unexpected field types', () async {
      final repo = SystemRepositoryImpl(
        gateway: fakeGateway(
          ipc: FakeNativeIpc({'STATUS_JSON': '{"drivers_active": "x"}'}),
          shell: FakeShell(_props),
        ),
      );

      expect(
        (await repo.getSystemState()).currentProfile,
        ProfileType.performance,
      );
    });
  });

  group('SystemRepositoryImpl setters', () {
    test('setProfile succeeds over IPC without forking a shell command',
        () async {
      final ipc = FakeNativeIpc({'APPLY': 'OK'});
      final shell = FakeShell(_props);
      final repo = SystemRepositoryImpl(
        gateway: fakeGateway(ipc: ipc, shell: shell),
      );

      await repo.setProfile(ProfileType.performance);

      expect(ipc.calls, ['APPLY performance']);
      expect(shell.commands.where((c) => c.startsWith('perfmtk ')), isEmpty);
    });

    test('setProfile falls back to the CLI', () async {
      final shell = FakeShell(_props);
      final repo = SystemRepositoryImpl(gateway: fakeGateway(shell: shell));

      await repo.setProfile(ProfileType.performance);

      expect(shell.commands, contains('perfmtk performance'));
    });

    test('setProfile fails when the daemon reports another profile', () async {
      final repo = SystemRepositoryImpl(
        gateway: fakeGateway(shell: FakeShell(_props)),
      );

      await expectLater(
        repo.setProfile(ProfileType.powersave),
        throwsA(isA<SystemCommandException>()),
      );
    });

    test('shell failures surface as SystemCommandException', () async {
      final repo = SystemRepositoryImpl(
        gateway: fakeGateway(shell: FailingShell()),
      );

      await expectLater(
        repo.setChargeBypass(true),
        throwsA(isA<SystemCommandException>()),
      );
      await expectLater(
        repo.setBatteryCare(true, 80),
        throwsA(isA<SystemCommandException>()),
      );
      await expectLater(
        repo.setChargeCurrentLimit(500),
        throwsA(isA<SystemCommandException>()),
      );
    });

    test('battery care sends limit through the CLI fallback', () async {
      final shell = FakeShell();
      final repo = SystemRepositoryImpl(gateway: fakeGateway(shell: shell));

      await repo.setBatteryCare(true, 85);
      await repo.setBatteryCare(false, 85);

      expect(shell.commands, ['perfmtk -b on 85', 'perfmtk -b off']);
    });
  });
}
