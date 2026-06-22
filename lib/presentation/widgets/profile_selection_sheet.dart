import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:installed_apps/app_info.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/presentation/widgets/profile_utils.dart';
import 'package:manager/presentation/widgets/custom_selection_tile.dart';

class ProfileSelectionSheet extends StatelessWidget {
  final AppInfo app;
  final ProfileType? currentProfile;
  final bool isSystemApp;
  final Function(ProfileType?) onProfileSelected;
  const ProfileSelectionSheet({
    super.key,
    required this.app,
    required this.currentProfile,
    this.isSystemApp = false,
    required this.onProfileSelected,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profiles = _buildProfiles(context);
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
            // Drag handle
            const SizedBox(height: AppConstants.spacing12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // App info header
            const SizedBox(height: AppConstants.spacing16),
            Padding(
              padding: AppConstants.paddingHorizontal,
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(AppConstants.radiusSmall),
                        child: Image.memory(
                          app.icon!,
                          width: 48,
                          height: 48,
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
                              color: theme.colorScheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.security_rounded,
                              size: 12,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: AppConstants.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppConstants.spacing4),
                        Text(
                          AppLocale.selectProfile.getString(context),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: AppConstants.spacing8),
            // Profile options
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final p = profiles[index];
                final isSelected = currentProfile == p.profileType;
                return _AnimatedSheetItem(
                  index: index,
                  child: SelectionTile(
                    icon: ProfileUtils.iconFor(p.profileType),
                    iconColor: ProfileUtils.colorFor(p.profileType),
                    title: p.name,
                    subtitle: p.description,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onProfileSelected(p.profileType);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: AppConstants.spacing16),
          ],
        ),
      ),
    );
  }
  List<_SheetProfileData> _buildProfiles(BuildContext context) {
    return [
      _SheetProfileData(
        profileType: null,
        name: AppLocale.defaultProfile.getString(context),
        description: AppLocale.defaultProfileDesc.getString(context),
      ),
      _SheetProfileData(
        profileType: ProfileType.performance,
        name: ProfileType.performance.displayName,
        description: AppLocale.performanceDesc.getString(context),
      ),
      _SheetProfileData(
        profileType: ProfileType.balanced,
        name: ProfileType.balanced.displayName,
        description: AppLocale.balancedDesc.getString(context),
      ),
      _SheetProfileData(
        profileType: ProfileType.powersave,
        name: ProfileType.powersave.displayName,
        description: AppLocale.powersaveDesc.getString(context),
      ),
      _SheetProfileData(
        profileType: ProfileType.powersavePlus,
        name: ProfileType.powersavePlus.displayName,
        description: AppLocale.powersavePlusDesc.getString(context),
      ),
    ];
  }
}
class _SheetProfileData {
  final ProfileType? profileType;
  final String name;
  final String description;
  const _SheetProfileData({
    required this.profileType,
    required this.name,
    required this.description,
  });
}

// ── Animated slide-in for each sheet item ─────────────────────────────────────
class _AnimatedSheetItem extends StatefulWidget {
  final Widget child;
  final int index;
  const _AnimatedSheetItem({required this.child, required this.index});
  @override
  State<_AnimatedSheetItem> createState() => _AnimatedSheetItemState();
}
class _AnimatedSheetItemState extends State<_AnimatedSheetItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: AppConstants.animationNormal);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 40 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
