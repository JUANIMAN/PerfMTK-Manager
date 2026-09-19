import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/custom_selection_tile.dart';
import 'package:manager/presentation/widgets/profile_utils.dart';

/// Bottom sheet dialog for picking the screen-off power profile.
class ScreenOffProfileSheet extends StatelessWidget {
  final ProfileType currentProfile;
  final ValueChanged<ProfileType> onProfileSelected;

  const ScreenOffProfileSheet({
    super.key,
    required this.currentProfile,
    required this.onProfileSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required ProfileType currentProfile,
    required ValueChanged<ProfileType> onProfileSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ScreenOffProfileSheet(
        currentProfile: currentProfile,
        onProfileSelected: onProfileSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profiles = ProfileType.values;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXLarge),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppConstants.spacing12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Padding(
              padding: AppConstants.paddingHorizontal,
              child: Row(
                children: [
                  Icon(
                    Icons.bedtime_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Text(
                    AppLocale.screenOffProfile.getString(context),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: AppConstants.spacing8),
            ...profiles.map((profile) {
              final isSelected = profile == currentProfile;
              final color = ProfileUtils.colorFor(profile);
              final icon = ProfileUtils.iconFor(profile);

              return SelectionTile(
                icon: icon,
                iconColor: color,
                title: ProfileUtils.nameFor(context, profile),
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop();
                  onProfileSelected(profile);
                },
              );
            }),
            const SizedBox(height: AppConstants.spacing16),
          ],
        ),
      ),
    );
  }
}
