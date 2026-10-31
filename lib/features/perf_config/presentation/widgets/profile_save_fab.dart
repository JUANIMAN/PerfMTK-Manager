import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/features/system/data/models/profile.dart';
import 'package:manager/features/perf_config/data/profile_config.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/perf_config/presentation/perf_config_provider.dart';

/// Floating Action Button with Revert and Save actions for hardware profile edits.
class ProfileSaveFab extends ConsumerWidget {
  final ProfileType profile;
  final ProfileEditorState editorState;
  final ProfileConfig savedConfig;
  final Color color;

  const ProfileSaveFab({
    super.key,
    required this.profile,
    required this.editorState,
    required this.savedConfig,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSaving = editorState.isSaving;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Revert button
        FloatingActionButton.small(
          heroTag: 'revert_${profile.value}',
          backgroundColor: isDark
              ? AppPalette.navy900.withValues(alpha: 0.90)
              : theme.colorScheme.surfaceContainerHighest,
          foregroundColor: theme.colorScheme.onSurfaceVariant,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.30),
              width: 1.0,
            ),
          ),
          onPressed: isSaving
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(profileEditorProvider(profile).notifier)
                      .revert(savedConfig);
                },
          tooltip: context.l10n.revertChanges,
          child: const Icon(Icons.undo_rounded),
        ),
        const SizedBox(width: AppConstants.spacing8),

        // Save button
        FloatingActionButton.extended(
          heroTag: 'save_${profile.value}',
          backgroundColor: isSaving ? color.withValues(alpha: 0.6) : color,
          foregroundColor: Colors.white,
          elevation: isSaving ? 0 : 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          onPressed: isSaving
              ? null
              : () async {
                  unawaited(HapticFeedback.mediumImpact());
                  final ok = await ref
                      .read(profileEditorProvider(profile).notifier)
                      .save();
                  if (context.mounted) {
                    final saveError = ref
                        .read(profileEditorProvider(profile))
                        .errorMessage;
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? context.l10n.configSaved
                              : (saveError ??
                                    context.l10n.configSaveError),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: ok ? null : theme.colorScheme.error,
                      ),
                    );
                  }
                },
          icon: isSaving
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                )
              : const Icon(Icons.save_rounded, size: 20),
          label: Text(
            isSaving
                ? context.l10n.savingConfig
                : context.l10n.saveChanges,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
