import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/providers/daemon_providers.dart';
import 'package:manager/features/backup/data/backup_entry.dart';
import 'package:manager/features/backup/data/backup_repository.dart';
import 'package:manager/features/perf_config/presentation/perf_config_provider.dart';
import 'package:manager/features/system/presentation/system_provider.dart';

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepositoryImpl(gateway: ref.watch(daemonGatewayProvider));
});

/// True while a backup mutation (create/restore/delete/reset) is running.
class BusyNotifier extends Notifier<bool> {
  int _running = 0;

  @override
  bool build() => false;

  /// Runs [task] keeping [state] true until every overlapping task is done.
  Future<T> run<T>(Future<T> Function() task) async {
    _running++;
    state = true;
    try {
      return await task();
    } finally {
      _running--;
      if (_running == 0 && ref.mounted) state = false;
    }
  }
}

final isPerformingBackupActionProvider = NotifierProvider<BusyNotifier, bool>(
  BusyNotifier.new,
);

class BackupListNotifier extends AsyncNotifier<List<BackupEntry>> {
  BackupRepository get _repo => ref.read(backupRepositoryProvider);

  @override
  Future<List<BackupEntry>> build() => _repo.getBackups();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repo.getBackups);
  }

  Future<bool> createBackup() => _mutate(_repo.createBackup);

  Future<bool> restoreBackup(String filename) =>
      _mutate(() => _repo.restoreBackup(filename), reloadsSystem: true);

  Future<bool> resetStockProfiles() =>
      _mutate(_repo.resetStockProfiles, reloadsSystem: true);

  Future<bool> deleteBackup(String filename) =>
      _mutate(() => _repo.deleteBackup(filename));

  Future<bool> deleteAllBackups() => _mutate(_repo.deleteAllBackups);

  /// Runs a repository mutation, then refreshes the list (and, when profiles
  /// changed on disk, invalidates cached device/system state).
  Future<bool> _mutate(
    Future<bool> Function() operation, {
    bool reloadsSystem = false,
  }) {
    return ref.read(isPerformingBackupActionProvider.notifier).run(() async {
      final success = await operation();
      if (success) {
        if (reloadsSystem) {
          ref.invalidate(deviceConfigProvider);
          unawaited(ref.read(systemStateProvider.notifier).refresh());
        }
        state = await AsyncValue.guard(_repo.getBackups);
      }
      return success;
    });
  }
}

final backupListProvider =
    AsyncNotifierProvider<BackupListNotifier, List<BackupEntry>>(
      BackupListNotifier.new,
    );
