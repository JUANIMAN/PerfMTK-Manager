import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:installed_apps/app_info.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/profile_selection_sheet.dart';
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
    final (Color profileColor, String profileName, IconData profileIcon) =
    _getProfileInfo(context);

    return Hero(
      tag: 'app_${app.packageName}',
      child: Card(
        margin: AppConstants.marginBottom,
        elevation: AppConstants.elevationNone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          side: BorderSide(
            color: currentProfile != null
                ? profileColor.border
                : Theme.of(context).dividerColor.light,
            width: currentProfile != null ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          onTap: () => _showProfileSelectionBottomSheet(context),
          child: Padding(
            padding: AppConstants.paddingNormal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAppIcon(context),
                    const SizedBox(width: AppConstants.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppConstants.spacing4),
                          Text(
                            app.packageName,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.subtle,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppConstants.spacing8),
                          _buildProfileChip(
                            context,
                            profileName,
                            profileColor,
                            profileIcon,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune),
                      tooltip: AppLocale.changeProfile.getString(context),
                      onPressed: () => _showProfileSelectionBottomSheet(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            boxShadow: [
              BoxShadow(
                color: Colors.black.light,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            child: Image.memory(
              app.icon!,
              width: AppConstants.iconSizeXXLarge,
              height: AppConstants.iconSizeXXLarge,
            ),
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
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.security,
                size: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileChip(
      BuildContext context,
      String profileName,
      Color profileColor,
      IconData profileIcon,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing8,
        vertical: AppConstants.spacing4,
      ),
      decoration: BoxDecoration(
        color: profileColor.light,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: profileColor.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            profileIcon,
            size: 14,
            color: profileColor,
          ),
          const SizedBox(width: AppConstants.spacing4),
          Text(
            profileName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: profileColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  (Color, String, IconData) _getProfileInfo(BuildContext context) {
    switch (currentProfile?.value) {
      case 'performance':
        return (
        Colors.orange,
        AppLocale.performance.getString(context),
        Icons.speed,
        );
      case 'balanced':
        return (
        Colors.blue,
        AppLocale.balanced.getString(context),
        Icons.balance,
        );
      case 'powersave':
        return (
        Colors.green,
        AppLocale.powersave.getString(context),
        Icons.battery_full,
        );
      case 'powersave+':
        return (
        Colors.teal,
        AppLocale.powersavePlus.getString(context),
        Icons.battery_saver,
        );
      default:
        return (
        Colors.grey,
        AppLocale.defaultProfile.getString(context),
        Icons.settings_applications,
        );
    }
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