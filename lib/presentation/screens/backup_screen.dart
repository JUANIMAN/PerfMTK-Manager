import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/data/models/backup_entry.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/providers/backup_provider.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen>
    with SingleTickerProviderStateMixin, EntryAnimationMixin {
  @override
  void initState() {
    super.initState();
    initEntryAnimation();
  }

  @override
  void dispose() {
    disposeEntryAnimation();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
      ),
    );
  }

  Future<void> _handleCreateBackup() async {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(backupListProvider.notifier);
    final success = await notifier.createBackup();
    if (!mounted) return;
    if (success) {
      HapticFeedback.lightImpact();
      _showSnackBar(AppLocale.backupCreatedSuccess.getString(context));
    } else {
      HapticFeedback.heavyImpact();
      _showSnackBar(AppLocale.backupCreateError.getString(context), isError: true);
    }
  }

  Future<void> _confirmRestore(BackupEntry entry) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.restore_rounded,
              color: Theme.of(ctx).colorScheme.primary,
            ),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: Text(
                AppLocale.confirmRestoreTitle.getString(ctx),
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocale.confirmRestoreMessage.getString(ctx),
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacing16),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(
                  color: Theme.of(ctx).colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 20,
                    color: Theme.of(ctx).colorScheme.primary,
                  ),
                  const SizedBox(width: AppConstants.spacing10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${entry.filename} (${entry.formattedSize})',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocale.updateCancel.getString(ctx)),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.restore_rounded, size: 18),
            label: Text(AppLocale.restoreBackup.getString(ctx)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final notifier = ref.read(backupListProvider.notifier);
      final success = await notifier.restoreBackup(entry.filename);
      if (!mounted) return;
      if (success) {
        HapticFeedback.lightImpact();
        _showSnackBar(AppLocale.restoreSuccess.getString(context));
      } else {
        HapticFeedback.heavyImpact();
        _showSnackBar(AppLocale.restoreError.getString(context), isError: true);
      }
    }
  }

  Future<void> _confirmDelete(BackupEntry entry) async {
    HapticFeedback.mediumImpact();
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: cs.error,
            ),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: Text(
                AppLocale.deleteBackupTitle.getString(ctx),
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocale.deleteBackupConfirm.getString(ctx),
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacing16),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing12),
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(
                  color: cs.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: cs.error,
                  ),
                  const SizedBox(width: AppConstants.spacing10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${entry.filename} (${entry.formattedSize})',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocale.updateCancel.getString(ctx)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: Text(AppLocale.delete.getString(ctx)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final notifier = ref.read(backupListProvider.notifier);
      final success = await notifier.deleteBackup(entry.filename);
      if (!mounted) return;
      if (success) {
        HapticFeedback.lightImpact();
        _showSnackBar(AppLocale.backupDeletedSuccess.getString(context));
      } else {
        HapticFeedback.heavyImpact();
        _showSnackBar(AppLocale.backupDeleteError.getString(context), isError: true);
      }
    }
  }

  Future<void> _confirmDeleteAll() async {
    HapticFeedback.heavyImpact();
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.delete_sweep_rounded,
              color: cs.error,
            ),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: Text(
                AppLocale.deleteAllBackupsTitle.getString(ctx),
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          AppLocale.deleteAllBackupsConfirm.getString(ctx),
          style: Theme.of(ctx).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocale.updateCancel.getString(ctx)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: Text(AppLocale.delete.getString(ctx)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final notifier = ref.read(backupListProvider.notifier);
      final success = await notifier.deleteAllBackups();
      if (!mounted) return;
      if (success) {
        HapticFeedback.lightImpact();
        _showSnackBar(AppLocale.allBackupsDeletedSuccess.getString(context));
      } else {
        HapticFeedback.heavyImpact();
        _showSnackBar(AppLocale.backupDeleteError.getString(context), isError: true);
      }
    }
  }

  Future<void> _confirmResetStock() async {
    HapticFeedback.heavyImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFFF9100),
            ),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: Text(
                AppLocale.resetStockTitle.getString(ctx),
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          AppLocale.resetStockConfirm.getString(ctx),
          style: Theme.of(ctx).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocale.updateCancel.getString(ctx)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF9100),
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.restore_page_rounded, size: 18),
            label: Text(AppLocale.resetStockTitle.getString(ctx)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final notifier = ref.read(backupListProvider.notifier);
      final success = await notifier.resetStockProfiles();
      if (!mounted) return;
      if (success) {
        HapticFeedback.lightImpact();
        _showSnackBar(AppLocale.resetStockSuccess.getString(context));
      } else {
        HapticFeedback.heavyImpact();
        _showSnackBar(AppLocale.restoreError.getString(context), isError: true);
      }
    }
  }

  String _formatTotalStorage(List<BackupEntry> list) {
    int totalBytes = 0;
    for (final e in list) {
      totalBytes += e.sizeBytes;
    }
    if (totalBytes <= 0) return '0 KB';
    return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final backupsAsync = ref.watch(backupListProvider);
    final isPerformingAction = ref.watch(isPerformingBackupActionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.backupManager.getString(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          tooltip: AppLocale.back.getString(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: isPerformingAction
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    ref.read(backupListProvider.notifier).refresh();
                  },
            tooltip: 'Refresh',
          ),
          backupsAsync.maybeWhen(
            data: (list) => list.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.delete_sweep_rounded,
                      color: cs.error.withValues(alpha: isPerformingAction ? 0.4 : 0.9),
                    ),
                    onPressed: isPerformingAction ? null : _confirmDeleteAll,
                    tooltip: AppLocale.deleteAllBackupsTitle.getString(context),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: AppConstants.spacing8),
        ],
      ),
      body: buildWithEntryAnimation(
        RefreshIndicator(
          onRefresh: () => ref.read(backupListProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing16,
                  vertical: AppConstants.spacing16,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── 1. Summary Statistics Dashboard Card ────────────
                    backupsAsync.maybeWhen(
                      data: (list) => Container(
                        margin: const EdgeInsets.only(bottom: AppConstants.spacing16),
                        padding: const EdgeInsets.all(AppConstants.spacing16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.4 : 0.6),
                          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                icon: Icons.folder_zip_rounded,
                                color: cs.primary,
                                title: '${list.length} / 16',
                                subtitle: AppLocale.backupsCountLabel.getString(context),
                              ),
                            ),
                            Container(
                              height: 36,
                              width: 1,
                              color: cs.outlineVariant.withValues(alpha: 0.3),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                icon: Icons.data_usage_rounded,
                                color: const Color(0xFF00E676),
                                title: _formatTotalStorage(list),
                                subtitle: AppLocale.storageUsed.getString(context),
                              ),
                            ),
                            Container(
                              height: 36,
                              width: 1,
                              color: cs.outlineVariant.withValues(alpha: 0.3),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                icon: Icons.tune_rounded,
                                color: const Color(0xFF2979FF),
                                title: '8 .conf',
                                subtitle: 'Profiles',
                              ),
                            ),
                          ],
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),

                    // ── 2. Create Backup Action Card ────────────────────
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacing16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: isDark ? 0.35 : 0.25),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppConstants.spacing10),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: isDark ? 0.16 : 0.12),
                                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                  border: Border.all(
                                    color: cs.primary.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add_moderator_rounded,
                                  color: cs.primary,
                                  size: AppConstants.iconSizeNormal,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacing14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocale.createBackup.getString(context),
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppLocale.createBackupDesc.getString(context),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacing16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: FilledButton.icon(
                              onPressed: isPerformingAction ? null : _handleCreateBackup,
                              icon: isPerformingAction
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.add_circle_outline_rounded, size: 18),
                              label: Text(
                                isPerformingAction
                                    ? AppLocale.creatingBackup.getString(context)
                                    : AppLocale.createBackup.getString(context),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacing24),

                    // ── 3. Section Header: Available Snapshots ──────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppConstants.spacing6),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                              ),
                              child: Icon(
                                Icons.history_rounded,
                                size: AppConstants.iconSizeSmall,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacing10),
                            Text(
                              AppLocale.backupTitle.getString(context),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        backupsAsync.whenOrNull(
                              data: (list) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${list.length} snapshots',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ) ??
                            const SizedBox.shrink(),
                      ],
                    ),

                    const SizedBox(height: AppConstants.spacing12),

                    // ── 4. List of Backups / Empty State ────────────────
                    backupsAsync.when(
                      data: (list) {
                        if (list.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(AppConstants.spacing32),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                              border: Border.all(
                                color: cs.outlineVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.folder_off_outlined,
                                  size: 48,
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: AppConstants.spacing12),
                                Text(
                                  AppLocale.noBackupsFound.getString(context),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacing6),
                                Text(
                                  AppLocale.noBackupsDesc.getString(context),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacing16),
                                OutlinedButton.icon(
                                  onPressed: isPerformingAction ? null : _handleCreateBackup,
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: Text(AppLocale.createBackup.getString(context)),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: list.map((entry) {
                            final isLatest = entry.index == 1;
                            return Container(
                              margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHigh.withValues(alpha: isDark ? 0.5 : 0.7),
                                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                                border: Border.all(
                                  color: isLatest
                                      ? cs.primary.withValues(alpha: isDark ? 0.45 : 0.35)
                                      : cs.outlineVariant.withValues(alpha: 0.25),
                                  width: isLatest ? 1.2 : 0.8,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppConstants.spacing14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header: Index Avatar + Date + Latest Badge + Delete Menu
                                    Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: isLatest
                                                ? cs.primaryContainer
                                                : cs.surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '#${entry.index}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isLatest
                                                  ? cs.primary
                                                  : cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppConstants.spacing10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      entry.date,
                                                      style: theme.textTheme.titleSmall?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (isLatest) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: cs.primary.withValues(alpha: 0.15),
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(
                                                          color: cs.primary.withValues(alpha: 0.3),
                                                          width: 0.6,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        AppLocale.backupLatestBadge.getString(context),
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.w800,
                                                          color: cs.primary,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                entry.filename,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: cs.onSurfaceVariant,
                                                  fontSize: 11,
                                                  fontFamily: 'monospace',
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: AppConstants.spacing12),

                                    // Tags: Size + Content
                                    Row(
                                      children: [
                                        _buildTag(
                                          icon: Icons.inventory_2_outlined,
                                          label: entry.formattedSize,
                                          color: cs.onSurfaceVariant,
                                          context: context,
                                        ),
                                        const SizedBox(width: AppConstants.spacing8),
                                        _buildTag(
                                          icon: Icons.tune_rounded,
                                          label: AppLocale.backupProfilesCount.getString(context),
                                          color: cs.onSurfaceVariant,
                                          context: context,
                                        ),
                                        const Spacer(),
                                        // Delete action button
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline_rounded,
                                            size: 20,
                                            color: cs.error.withValues(alpha: isPerformingAction ? 0.3 : 0.8),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          tooltip: AppLocale.delete.getString(context),
                                          onPressed: isPerformingAction ? null : () => _confirmDelete(entry),
                                        ),
                                        const SizedBox(width: AppConstants.spacing4),
                                        // Restore button
                                        FilledButton.tonalIcon(
                                          style: FilledButton.styleFrom(
                                            visualDensity: VisualDensity.compact,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppConstants.spacing12,
                                              vertical: AppConstants.spacing6,
                                            ),
                                          ),
                                          icon: const Icon(Icons.settings_backup_restore_rounded, size: 16),
                                          label: Text(
                                            AppLocale.restoreBackup.getString(context),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                          onPressed: isPerformingAction ? null : () => _confirmRestore(entry),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.spacing24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (err, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.spacing16),
                          child: Text(
                            err.toString(),
                            style: TextStyle(color: cs.error),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacing24),

                    // ── 5. Factory Reset Section (Warning Danger Zone) ──
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacing16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9100).withValues(alpha: isDark ? 0.08 : 0.05),
                        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                        border: Border.all(
                          color: const Color(0xFFFF9100).withValues(alpha: isDark ? 0.35 : 0.25),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.settings_backup_restore_rounded,
                                color: Color(0xFFFF9100),
                                size: 22,
                              ),
                              const SizedBox(width: AppConstants.spacing10),
                              Text(
                                AppLocale.resetStockTitle.getString(context),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF9100),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacing8),
                          Text(
                            AppLocale.resetStockDesc.getString(context),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacing16),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFF9100),
                              side: BorderSide(
                                color: const Color(0xFFFF9100).withValues(alpha: 0.5),
                              ),
                            ),
                            icon: const Icon(Icons.restart_alt_rounded, size: 18),
                            label: Text(AppLocale.resetStockTitle.getString(context)),
                            onPressed: isPerformingAction ? null : _confirmResetStock,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacing40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
