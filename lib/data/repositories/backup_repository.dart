import 'dart:convert';
import 'package:manager/core/native_ipc_channel.dart';
import 'package:manager/core/root_shell_manager.dart';
import 'package:manager/data/models/backup_entry.dart';

class BackupRepository {
  final NativeIpcChannel _ipc = NativeIpcChannel();
  final RootShellManager _shell = RootShellManager();

  /// Retrieves the list of available profile backup snapshots sorted newest to oldest.
  Future<List<BackupEntry>> getBackups() async {
    // Tier 1: Fast Native Socket IPC (Zero Process Fork)
    try {
      final jsonStr = await _ipc.sendCommand('LIST_BACKUPS');
      if (jsonStr != null && jsonStr.trim().startsWith('[')) {
        final List<dynamic> list = jsonDecode(jsonStr.trim()) as List<dynamic>;
        if (list.isNotEmpty) {
          return list.map((e) => BackupEntry.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}

    // Tier 2: Direct Directory File Scan (Completely independent of CLI ANSI / Daemons)
    try {
      final lsOutput = await _shell.executeCommand('ls -l /data/adb/modules/perfmtk/config/backups/');
      final lines = lsOutput.split('\n');
      final entries = <BackupEntry>[];
      for (final line in lines) {
        final match = RegExp(r'profiles_(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})\.tar\.gz').firstMatch(line);
        if (match != null) {
          final year = match.group(1);
          final mon = match.group(2);
          final day = match.group(3);
          final hour = match.group(4);
          final min = match.group(5);
          final sec = match.group(6);
          final filename = match.group(0)!;
          
          final parts = line.trim().split(RegExp(r'\s+'));
          int size = 1600;
          if (parts.length >= 5) {
            size = int.tryParse(parts[4]) ?? 1600;
          }

          entries.add(
            BackupEntry(
              index: 0,
              filename: filename,
              date: '$year-$mon-$day $hour:$min:$sec',
              sizeBytes: size,
            ),
          );
        }
      }

      if (entries.isNotEmpty) {
        entries.sort((a, b) => b.filename.compareTo(a.filename));
        return List.generate(
          entries.length,
          (i) => BackupEntry(
            index: i + 1,
            filename: entries[i].filename,
            date: entries[i].date,
            sizeBytes: entries[i].sizeBytes,
          ),
        );
      }
    } catch (_) {}

    return [];
  }

  /// Creates a new timestamped backup archive of all current .conf profiles.
  Future<bool> createBackup() async {
    try {
      final resp = await _ipc.sendCommand('BACKUP');
      if (resp != null && resp.trim().startsWith('OK:')) {
        return true;
      }
    } catch (_) {}

    try {
      await _shell.executeCommand('/data/adb/modules/perfmtk/system/bin/perfmtk --backup');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Restores a selected backup archive by filename.
  Future<bool> restoreBackup(String filename) async {
    try {
      final resp = await _ipc.sendCommand('RESTORE', filename);
      if (resp != null && resp.trim().startsWith('OK:')) {
        return true;
      }
    } catch (_) {}

    try {
      await _shell.executeCommand('/data/adb/modules/perfmtk/system/bin/perfmtk --restore "$filename"');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Restores stock factory configuration profiles with an automatic safety backup.
  Future<bool> resetStockProfiles() async {
    try {
      final resp = await _ipc.sendCommand('RESET_STOCK');
      if (resp != null && resp.trim().startsWith('OK:')) {
        return true;
      }
    } catch (_) {}

    try {
      await _shell.executeCommand(
        '/data/adb/modules/perfmtk/system/bin/perfmtk --backup && /data/adb/modules/perfmtk/system/bin/perfmtk -g && /data/adb/modules/perfmtk/system/bin/perfmtk -r',
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
