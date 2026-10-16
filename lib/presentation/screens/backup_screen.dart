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
                    // ── Hero Action Card ─────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacing20),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: isDark ? 0.35 : 0.25),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppConstants.spacing12),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: isDark ? 0.16 : 0.12),
                                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                                  border: Border.all(
                                    color: cs.primary.withValues(alpha: 0.4),
                                    width: 0.8,
                                  ),
                                ),
                                child: Icon(
                                  Icons.security_rounded,
                                  color: cs.primary,
                                  size: AppConstants.iconSizeLarge,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacing16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocale.backupTitle.getString(context),
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: AppConstants.spacing4),
                                    Text(
                                      AppLocale.backupSubtitle.getString(context),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacing20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton.icon(
                              onPressed: isPerformingAction ? null : _handleCreateBackup,
                              icon: isPerformingAction
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.add_circle_outline_rounded),
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

                    // ── Header: Snapshots Disponibles ────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'COPIAS DISPONIBLES',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        backupsAsync.whenOrNull(
                              data: (list) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${list.length} / 16',
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

                    // ── List of Backups ──────────────────────────────────
                    backupsAsync.when(
                      data: (list) {
                        if (list.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(AppConstants.spacing32),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              border: Border.all(
                                color: cs.outlineVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.folder_open_rounded,
                                  size: 48,
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                                ),
                                const SizedBox(height: AppConstants.spacing12),
                                Text(
                                  AppLocale.noBackupsFound.getString(context),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.spacing4),
                                Text(
                                  AppLocale.noBackupsDesc.getString(context),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: list.map((entry) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                                border: Border.all(
                                  color: cs.outlineVariant.withValues(alpha: 0.25),
                                  width: 0.8,
                                ),
                              ),
                              padding: const EdgeInsets.all(AppConstants.spacing16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppConstants.spacing10),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.08),
                                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                                    ),
                                    child: Icon(
                                      Icons.archive_outlined,
                                      color: cs.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: AppConstants.spacing14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.date,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${entry.filename} · ${entry.formattedSize}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppConstants.spacing8),
                                  FilledButton.tonalIcon(
                                    style: FilledButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppConstants.spacing12,
                                        vertical: AppConstants.spacing8,
                                      ),
                                    ),
                                    icon: const Icon(Icons.restore_rounded, size: 16),
                                    label: Text(AppLocale.restoreBackup.getString(context)),
                                    onPressed: isPerformingAction ? null : () => _confirmRestore(entry),
                                  ),
                                ],
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

                    const SizedBox(height: AppConstants.spacing28),

                    // ── Reset to Stock Factory Section ───────────────────
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
}
