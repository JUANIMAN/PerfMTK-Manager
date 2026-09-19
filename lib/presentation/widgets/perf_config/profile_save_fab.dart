import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/profile_config.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/providers/perf_config_provider.dart';

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
              ? const Color(0xFF161F30).withValues(alpha: 0.90)
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
          tooltip: AppLocale.revertChanges.getString(context),
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
                  HapticFeedback.mediumImpact();
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
                              ? AppLocale.configSaved.getString(context)
                              : (saveError ??
                                    AppLocale.configSaveError.getString(
                                      context,
                                    )),
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
                ? AppLocale.savingConfig.getString(context)
                : AppLocale.saveChanges.getString(context),
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
