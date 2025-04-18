import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:installed_apps/app_info.dart';
import 'package:manager/localization/app_locales.dart';

class ProfileSelectionSheet extends StatelessWidget {
  final AppInfo app;
  final String currentProfile;
  final Function(String) onProfileSelected;

  const ProfileSelectionSheet({
    super.key,
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
                    app.icon!,
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
                        app.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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

          // Profile options with staggered animation
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              final isSelected = currentProfile == profile['value'] ||
                  (currentProfile.isEmpty && profile['value'] == '');

              return _AnimatedListItem(
                index: index,
                child: ListTile(
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
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
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
      duration: const Duration(milliseconds: 400),
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
