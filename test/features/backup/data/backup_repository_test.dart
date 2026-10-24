import 'package:flutter_test/flutter_test.dart';
import 'package:manager/features/backup/data/backup_list_parser.dart';
import 'package:manager/features/backup/data/backup_repository.dart';

import '../../../support/fakes.dart';

const _ls = '''
total 24
-rw------- 1 root root 1634 2026-01-02 10:00 profiles_20260102_100000.tar.gz
-rw------- 1 root root 2048 2026-03-04 11:22 profiles_20260304_112233.tar.gz
-rw------- 1 root root 9 2026-03-04 11:22 notes.txt
''';

void main() {
  group('BackupListParser', () {
    test('lists backups newest first with 1-based indexes', () {
      final entries = BackupListParser.parseLsOutput(_ls);

      expect(entries.map((e) => e.filename), [
        'profiles_20260304_112233.tar.gz',
        'profiles_20260102_100000.tar.gz',
      ]);
      expect(entries.map((e) => e.index), [1, 2]);
      expect(entries.first.date, '2026-03-04 11:22:33');
      expect(entries.first.sizeBytes, 2048);
    });

    test('reports unreadable size as zero and ignores unrelated files', () {
      final entries = BackupListParser.parseLsOutput(
        'profiles_20260102_100000.tar.gz',
      );
      expect(entries.single.sizeBytes, 0);
      expect(BackupListParser.parseLsOutput('nothing'), isEmpty);
    });
  });

  group('BackupRepositoryImpl', () {
    test('reads the backup list from IPC when available', () async {
      final repo = BackupRepositoryImpl(
        gateway: fakeGateway(
          ipc: FakeNativeIpc({
            'LIST_BACKUPS':
                '[{"index":1,"filename":"profiles_20260102_100000.tar.gz",'
                '"date":"2026-01-02 10:00:00","size_bytes":10}]',
          }),
        ),
      );

      final backups = await repo.getBackups();

      expect(backups.single.sizeBytes, 10);
    });

    test('scans the directory when IPC is unavailable or returns no data',
        () async {
      final repo = BackupRepositoryImpl(
        gateway: fakeGateway(
          ipc: FakeNativeIpc({'LIST_BACKUPS': '[]'}),
          shell: FakeShell((_) => _ls),
        ),
      );

      expect(await repo.getBackups(), hasLength(2));
    });

    test('returns an empty list when nothing can be read', () async {
      final repo = BackupRepositoryImpl(
        gateway: fakeGateway(shell: FailingShell()),
      );
      expect(await repo.getBackups(), isEmpty);
    });

    test('mutations succeed over IPC only on an "OK:" reply', () async {
      final ipc = FakeNativeIpc({'BACKUP': 'OK:done'});
      final shell = FakeShell();
      final repo = BackupRepositoryImpl(
        gateway: fakeGateway(ipc: ipc, shell: shell),
      );

      expect(await repo.createBackup(), isTrue);
      expect(shell.commands, isEmpty);
    });

    test('mutations fall back to the CLI and report failures as false',
        () async {
      final shell = FakeShell();
      final okRepo = BackupRepositoryImpl(gateway: fakeGateway(shell: shell));
      expect(await okRepo.restoreBackup('profiles_1.tar.gz'), isTrue);
      expect(await okRepo.deleteAllBackups(), isTrue);
      expect(shell.commands.first, contains('--restore "profiles_1.tar.gz"'));

      final failing = BackupRepositoryImpl(
        gateway: fakeGateway(shell: FailingShell()),
      );
      expect(await failing.createBackup(), isFalse);
      expect(await failing.deleteBackup('x'), isFalse);
      expect(await failing.resetStockProfiles(), isFalse);
    });
  });
}
