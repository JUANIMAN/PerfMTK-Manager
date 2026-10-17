import 'package:flutter_test/flutter_test.dart';
import 'package:manager/core/platform/daemon_gateway.dart';

import '../support/fakes.dart';

void main() {
  group('DaemonGateway.extractJsonObject', () {
    test('skips banner noise around the object', () {
      final json = DaemonGateway.extractJsonObject(
        'PerfMTK v16\n{"a": 1, "b": {"c": 2}}\n\u001b[0m',
      );
      expect(json, {
        'a': 1,
        'b': {'c': 2},
      });
    });

    test('returns null for missing, malformed or non-object payloads', () {
      expect(DaemonGateway.extractJsonObject(''), isNull);
      expect(DaemonGateway.extractJsonObject('no json here'), isNull);
      expect(DaemonGateway.extractJsonObject('{broken'), isNull);
      expect(DaemonGateway.extractJsonObject('} {'), isNull);
    });
  });

  group('DaemonGateway.command', () {
    test('does not touch the shell when IPC acknowledges', () async {
      final ipc = FakeNativeIpc({'APPLY': 'OK balanced'});
      final shell = FakeShell();
      final gateway = fakeGateway(ipc: ipc, shell: shell);

      await gateway.command('APPLY', arg: 'balanced', shellFallback: 'perfmtk x');

      expect(ipc.calls, ['APPLY balanced']);
      expect(shell.commands, isEmpty);
    });

    test('falls back to the shell when IPC is unavailable', () async {
      final shell = FakeShell();
      final gateway = fakeGateway(shell: shell);

      await gateway.command('APPLY', shellFallback: 'perfmtk x');

      expect(shell.commands, ['perfmtk x']);
    });

    test('falls back to the shell when IPC replies with an error', () async {
      final ipc = FakeNativeIpc({'APPLY': 'ERR nope'});
      final shell = FakeShell();

      await fakeGateway(ipc: ipc, shell: shell)
          .command('APPLY', shellFallback: 'perfmtk x');

      expect(shell.commands, ['perfmtk x']);
    });

    test('honors a custom ok prefix', () async {
      final ipc = FakeNativeIpc({'BACKUP': 'OK'});
      final shell = FakeShell();

      await fakeGateway(ipc: ipc, shell: shell).command(
        'BACKUP',
        shellFallback: 'perfmtk --backup',
        okPrefix: 'OK:',
      );

      expect(shell.commands, ['perfmtk --backup']);
    });
  });
}
