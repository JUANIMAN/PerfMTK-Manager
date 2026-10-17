import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/data/models/backup_entry.dart';
import 'package:manager/core/providers/daemon_providers.dart';
import 'package:manager/data/repositories/backup_repository.dart';
import 'package:manager/presentation/providers/perf_config_provider.dart';
import 'package:manager/presentation/providers/system_provider.dart';

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepositoryImpl(gateway: ref.watch(daemonGatewayProvider));
});

final isPerformingBackupActionProvider =
    NotifierProvider<BooleanNotifier, bool>(BooleanNotifier.new);

class BackupListNotifier extends AsyncNotifier<List<BackupEntry>> {
  @override
  Future<List<BackupEntry>> build() async {
    return _fetchBackups();
  }

  Future<List<BackupEntry>> _fetchBackups() async {
    final repo = ref.read(backupRepositoryProvider);
    return repo.getBackups();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchBackups());
  }

  Future<bool> createBackup() async {
    final repo = ref.read(backupRepositoryProvider);
    ref.read(isPerformingBackupActionProvider.notifier).state = true;
    try {
      final success = await repo.createBackup();
      if (success) {
        state = await AsyncValue.guard(() => _fetchBackups());
      }
      return success;
    } finally {
      ref.read(isPerformingBackupActionProvider.notifier).state = false;
    }
  }

  Future<bool> restoreBackup(String filename) async {
    final repo = ref.read(backupRepositoryProvider);
    ref.read(isPerformingBackupActionProvider.notifier).state = true;
    try {
      final success = await repo.restoreBackup(filename);
      if (success) {
        // Invalidate configuration and system caches
        ref.invalidate(deviceConfigProvider);
        ref.read(systemStateProvider.notifier).refresh();
        state = await AsyncValue.guard(() => _fetchBackups());
      }
      return success;
    } finally {
      ref.read(isPerformingBackupActionProvider.notifier).state = false;
    }
  }

  Future<bool> resetStockProfiles() async {
    final repo = ref.read(backupRepositoryProvider);
    ref.read(isPerformingBackupActionProvider.notifier).state = true;
    try {
      final success = await repo.resetStockProfiles();
      if (success) {
        // Invalidate configuration and system caches
        ref.invalidate(deviceConfigProvider);
        ref.read(systemStateProvider.notifier).refresh();
        state = await AsyncValue.guard(() => _fetchBackups());
      }
      return success;
    } finally {
      ref.read(isPerformingBackupActionProvider.notifier).state = false;
    }
  }

  Future<bool> deleteBackup(String filename) async {
    final repo = ref.read(backupRepositoryProvider);
    ref.read(isPerformingBackupActionProvider.notifier).state = true;
    try {
      final success = await repo.deleteBackup(filename);
      if (success) {
        state = await AsyncValue.guard(() => _fetchBackups());
      }
      return success;
    } finally {
      ref.read(isPerformingBackupActionProvider.notifier).state = false;
    }
  }

  Future<bool> deleteAllBackups() async {
    final repo = ref.read(backupRepositoryProvider);
    ref.read(isPerformingBackupActionProvider.notifier).state = true;
    try {
      final success = await repo.deleteAllBackups();
      if (success) {
        state = await AsyncValue.guard(() => _fetchBackups());
      }
      return success;
    } finally {
      ref.read(isPerformingBackupActionProvider.notifier).state = false;
    }
  }
}

final backupListProvider =
    AsyncNotifierProvider<BackupListNotifier, List<BackupEntry>>(
  BackupListNotifier.new,
);
