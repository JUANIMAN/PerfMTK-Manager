import 'package:flutter/material.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/features/backup/data/backup_entry.dart';
import 'package:manager/l10n/l10n.dart';

/// Confirmation dialogs for the backup manager. Each returns `true` when the
/// user confirms, `false`/`null` otherwise.

Future<bool?> showRestoreBackupDialog(BuildContext context, BackupEntry entry) {
  return showDialog<bool>(
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
              ctx.l10n.confirmRestoreTitle,
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
            ctx.l10n.confirmRestoreMessage,
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
          child: Text(ctx.l10n.updateCancel),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.restore_rounded, size: 18),
          label: Text(ctx.l10n.restoreBackup),
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
}

Future<bool?> showDeleteBackupDialog(BuildContext context, BackupEntry entry) {
  final cs = Theme.of(context).colorScheme;
  return showDialog<bool>(
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
              ctx.l10n.deleteBackupTitle,
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
            ctx.l10n.deleteBackupConfirm,
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
          child: Text(ctx.l10n.updateCancel),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
          ),
          icon: const Icon(Icons.delete_forever_rounded, size: 18),
          label: Text(ctx.l10n.delete),
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
}

Future<bool?> showDeleteAllBackupsDialog(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return showDialog<bool>(
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
              ctx.l10n.deleteAllBackupsTitle,
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        ctx.l10n.deleteAllBackupsConfirm,
        style: Theme.of(ctx).textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(ctx.l10n.updateCancel),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
          ),
          icon: const Icon(Icons.delete_forever_rounded, size: 18),
          label: Text(ctx.l10n.delete),
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
}

Future<bool?> showResetStockDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppPalette.vividOrange,
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Text(
              ctx.l10n.resetStockTitle,
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        ctx.l10n.resetStockConfirm,
        style: Theme.of(ctx).textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(ctx.l10n.updateCancel),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.vividOrange,
            foregroundColor: Colors.black,
          ),
          icon: const Icon(Icons.restore_page_rounded, size: 18),
          label: Text(ctx.l10n.resetStockTitle),
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
}

