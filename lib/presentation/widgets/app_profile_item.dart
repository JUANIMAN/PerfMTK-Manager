import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:installed_apps/app_info.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/profile_selection_sheet.dart';
import 'package:manager/presentation/widgets/profile_utils.dart';
import 'package:manager/config/app_constants.dart';
class AppProfileItem extends StatelessWidget {
  final AppInfo app;
  final ProfileType? currentProfile;
  final bool isSystemApp;
  final Function(ProfileType?) onProfileSelected;
  const AppProfileItem({
    super.key,
    required this.app,
    required this.currentProfile,
    this.isSystemApp = false,
    required this.onProfileSelected,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = ProfileUtils.colorFor(currentProfile);
    final icon = ProfileUtils.iconFor(currentProfile);
    final isConfigured = currentProfile != null;

    final borderColor = isConfigured
        ? color.withValues(alpha: 0.35)
        : cs.outlineVariant;
    final bgColor = isConfigured
        ? color.withValues(alpha: 0.02)
        : cs.surface;

    // RepaintBoundary isolates each item's repaint from its siblings
    return RepaintBoundary(
      child: Padding(
        padding: AppConstants.marginBottom,
          child: Material(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
              onTap: () => _showProfileSelectionBottomSheet(context),
              splashColor: isConfigured
                  ? color.withValues(alpha: 0.12)
                  : cs.primary.withValues(alpha: 0.06),
              highlightColor: isConfigured
                  ? color.withValues(alpha: 0.06)
                  : cs.primary.withValues(alpha: 0.03),
              child: Container(
                padding: AppConstants.paddingNormal,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                  border: Border.all(
                    color: borderColor,
                    width: isConfigured ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    _buildAppIcon(context),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            app.packageName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppConstants.spacing6),
                          _buildProfileChip(context, color, icon),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: cs.onSurfaceVariant,
                      size: AppConstants.iconSizeMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
  Widget _buildAppIcon(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          child: Image.memory(
            app.icon!,
            width: 44,
            height: 44,
            // cacheWidth reduces GPU memory: 44 logical × 3 density = 132px max,
            // so 96 is sufficient for most screens and saves ~60% VRAM vs unscaled.
            cacheWidth: 96,
            fit: BoxFit.cover,
          ),
        ),
        if (isSystemApp)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.security_rounded,
                size: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
  Widget _buildProfileChip(
      BuildContext context,
      Color color,
      IconData icon,
      ) {
    final label = currentProfile == null
        ? AppLocale.defaultProfile.getString(context)
        : currentProfile!.displayName;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
  void _showProfileSelectionBottomSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileSelectionSheet(
        app: app,
        currentProfile: currentProfile,
        isSystemApp: isSystemApp,
        onProfileSelected: (profile) {
          Navigator.of(context).pop();
          onProfileSelected(profile);
        },
      ),
    );
  }
}