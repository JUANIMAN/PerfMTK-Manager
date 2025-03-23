import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:device_apps/device_apps.dart';
import 'package:manager/localization/app_locales.dart';

class AppProfileItem extends StatelessWidget {
  final ApplicationWithIcon app;
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

    return Card(
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
                        app.icon,
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
                          app.appName,
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
      builder: (context) => _ProfileSelectionSheet(
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

class _ProfileSelectionSheet extends StatelessWidget {
  final ApplicationWithIcon app;
  final String currentProfile;
  final Function(String) onProfileSelected;

  const _ProfileSelectionSheet({
    required this.app,
    required this.currentProfile,
    required this.onProfileSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> profiles = [
      {
        'value': '',
        'name': AppLocale.defaultProfile.getString(context),
        'icon': Icons.settings_applications,
        'color': Colors.grey,
        'description': AppLocale.defaultProfileDesc.getString(context),
      },
      {
        'value': 'performance',
        'name': AppLocale.performance.getString(context),
        'icon': Icons.speed,
        'color': Colors.orange,
        'description': AppLocale.performanceDesc.getString(context),
      },
      {
        'value': 'balanced',
        'name': AppLocale.balanced.getString(context),
        'icon': Icons.balance,
        'color': Colors.blue,
        'description': AppLocale.balancedDesc.getString(context),
      },
      {
        'value': 'powersave',
        'name': AppLocale.powersave.getString(context),
        'icon': Icons.battery_full,
        'color': Colors.green,
        'description': AppLocale.powersaveDesc.getString(context),
      },
      {
        'value': 'powersave+',
        'name': AppLocale.powersavePlus.getString(context),
        'icon': Icons.battery_saver,
        'color': Colors.teal,
        'description': AppLocale.powersavePlusDesc.getString(context),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),

          // App info header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    app.icon,
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.appName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocale.selectProfile.getString(context),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),

          // Profile options
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              final isSelected = currentProfile == profile['value'] ||
                  (currentProfile.isEmpty && profile['value'] == '');

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: profile['color'].withOpacity(0.1),
                  child: Icon(
                    profile['icon'],
                    color: profile['color'],
                  ),
                ),
                title: Text(
                  profile['name'],
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  profile['description'],
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: isSelected
                    ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
                    : null,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onProfileSelected(profile['value']);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}