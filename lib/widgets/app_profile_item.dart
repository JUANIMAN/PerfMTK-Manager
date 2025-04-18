import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:installed_apps/app_info.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/widgets/profile_selection_sheet.dart';

class AppProfileItem extends StatelessWidget {
  final AppInfo app;
  final String currentProfile;
  final Function(String) onProfileSelected;

  const AppProfileItem({
    super.key,
    required this.app,
    required this.currentProfile,
    required this.onProfileSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar color y texto del perfil actual
    final (Color profileColor, String profileName, IconData profileIcon) = _getProfileInfo(context);

    return Hero(
      tag: 'app_${app.packageName}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: currentProfile.isNotEmpty
                ? profileColor.withOpacity(0.3)
                : Theme.of(context).dividerColor.withOpacity(0.1),
            width: currentProfile.isNotEmpty ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showProfileSelectionBottomSheet(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // App icon with shadow
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          app.icon!,
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            app.packageName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Current profile chip
                          _buildProfileChip(context, profileName, profileColor, profileIcon),
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

  Widget _buildProfileChip(BuildContext context, String profileName, Color profileColor, IconData profileIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: profileColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: profileColor.withOpacity(0.3),
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
          const SizedBox(width: 4),
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
    switch (currentProfile) {
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
        onProfileSelected: (profile) {
          Navigator.of(context).pop();
          onProfileSelected(profile);
        },
      ),
    );
  }
}
