import 'dart:convert';

import 'package:manager/core/errors/app_exception.dart';
import 'package:manager/core/logging/app_logger.dart';
import 'package:manager/core/platform/daemon_gateway.dart';
import 'package:manager/core/platform/perfmtk_paths.dart';
import 'package:manager/features/backup/data/backup_entry.dart';
import 'package:manager/features/backup/data/backup_list_parser.dart';

/// Profile backup snapshots (`profiles_YYYYMMDD_HHMMSS.tar.gz`).
abstract class BackupRepository {
  /// Backups sorted newest to oldest.
  Future<List<BackupEntry>> getBackups();

  /// Each mutating call returns true on success and false on failure
  /// (the failure reason is logged).
  Future<bool> createBackup();
  Future<bool> restoreBackup(String filename);
  Future<bool> resetStockProfiles();
  Future<bool> deleteBackup(String filename);
  Future<bool> deleteAllBackups();
}

class BackupRepositoryImpl implements BackupRepository {
  static const String _tag = 'BackupRepository';
  static const String _okPrefix = 'OK:';
  static const String _cli = PerfMtkPaths.binary;

  final DaemonGateway _gateway;

  const BackupRepositoryImpl({required DaemonGateway gateway})
    : _gateway = gateway;

  @override
  Future<List<BackupEntry>> getBackups() async {
    // Tier 1: Fast Native Socket IPC (Zero Process Fork)
    final resp = await _gateway.ipc('LIST_BACKUPS');
    final trimmed = resp?.trim();
    if (trimmed != null && trimmed.startsWith('[')) {
      try {
        final list = (jsonDecode(trimmed) as List<dynamic>)
            .map((e) => BackupEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      } on FormatException catch (e) {
        AppLogger.warn(_tag, 'invalid LIST_BACKUPS payload', e);
      } on TypeError catch (e) {
        AppLogger.warn(_tag, 'unexpected LIST_BACKUPS payload shape', e);
      }
    }

    // Tier 2: Direct directory scan (independent of CLI ANSI output / daemon).
    try {
      final lsOutput = await _gateway.shell(
        'ls -l ${PerfMtkPaths.backupsDir}/',
      );
      return BackupListParser.parseLsOutput(lsOutput);
    } on RootShellException catch (e) {
      AppLogger.warn(_tag, 'listing backups via shell failed', e);
      return [];
    }
  }

  @override
  Future<bool> createBackup() =>
      _run('create', 'BACKUP', shell: '$_cli --backup');

  @override
  Future<bool> restoreBackup(String filename) => _run(
    'restore',
    'RESTORE',
    arg: filename,
    shell: '$_cli --restore "$filename"',
  );

  @override
  Future<bool> resetStockProfiles() => _run(
    'reset to stock',
    'RESET_STOCK',
    shell: '$_cli --backup && $_cli -g && $_cli -r',
  );

  @override
  Future<bool> deleteBackup(String filename) => _run(
    'delete',
    'DELETE_BACKUP',
    arg: filename,
    shell: 'rm -f "${PerfMtkPaths.backupsDir}/$filename"',
  );

  @override
  Future<bool> deleteAllBackups() => _run(
    'delete all',
    'DELETE_BACKUP',
    arg: 'all',
    shell: 'rm -f ${PerfMtkPaths.backupsDir}/profiles_*.tar.gz',
  );

  Future<bool> _run(
    String label,
    String ipcCommand, {
    String? arg,
    required String shell,
  }) async {
    try {
      await _gateway.command(
        ipcCommand,
        arg: arg,
        shellFallback: shell,
        okPrefix: _okPrefix,
      );
      return true;
    } on RootShellException catch (e) {
      AppLogger.warn(_tag, 'backup $label failed', e);
      return false;
    }
  }
}
