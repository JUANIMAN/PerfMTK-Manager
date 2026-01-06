import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:installed_apps/app_info.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/presentation/widgets/custom_selection_tile.dart';

class ProfileSelectionSheet extends StatelessWidget {
  final AppInfo app;
  final ProfileType? currentProfile;
  final Function(ProfileType?) onProfileSelected;

  const ProfileSelectionSheet({
    super.key,
    required this.app,
    required this.currentProfile,
    required this.onProfileSelected,
  });

  @override
  Widget build(BuildContext context) {
    final profiles = _buildProfiles(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXLarge),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: AppConstants.spacing12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // App info header
            const SizedBox(height: AppConstants.spacing16),
            Padding(
              padding: AppConstants.paddingHorizontal,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    child: Image.memory(
                      app.icon!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing16),
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
                        const SizedBox(height: AppConstants.spacing4),
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

            const SizedBox(height: AppConstants.spacing20),
            const Divider(height: 1),
            const SizedBox(height: AppConstants.spacing8),

            // Profile options
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final profile = profiles[index];
                final isSelected = currentProfile == profile.value;

                return _AnimatedListItem(
                  index: index,
                  child: SelectionTile(
                    icon: profile.icon,
                    iconColor: profile.color,
                    title: profile.name,
                    subtitle: profile.description,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onProfileSelected(profile.value);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: AppConstants.spacing20),
          ],
        ),
      ),
    );
  }

  List<ProfileData> _buildProfiles(BuildContext context) {
    return [
      ProfileData(
        value: null,
        name: AppLocale.defaultProfile.getString(context),
        icon: Icons.settings_applications,
        color: Colors.grey,
        description: AppLocale.defaultProfileDesc.getString(context),
      ),
      ProfileData(
        value: ProfileType.performance,
        name: AppLocale.performance.getString(context),
        icon: Icons.speed,
        color: Colors.orange,
        description: AppLocale.performanceDesc.getString(context),
      ),
      ProfileData(
        value: ProfileType.balanced,
        name: AppLocale.balanced.getString(context),
        icon: Icons.balance,
        color: Colors.blue,
        description: AppLocale.balancedDesc.getString(context),
      ),
      ProfileData(
        value: ProfileType.powersave,
        name: AppLocale.powersave.getString(context),
        icon: Icons.battery_full,
        color: Colors.green,
        description: AppLocale.powersaveDesc.getString(context),
      ),
      ProfileData(
        value: ProfileType.powersavePlus,
        name: AppLocale.powersavePlus.getString(context),
        icon: Icons.battery_saver,
        color: Colors.teal,
        description: AppLocale.powersavePlusDesc.getString(context),
      ),
    ];
  }
}

// Clase helper para los datos del perfil
class ProfileData {
  final ProfileType? value;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  ProfileData({
    required this.value,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class _AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedListItem({
    required this.child,
    required this.index,
  });

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animationSlow,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Animar con delay escalonado
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}