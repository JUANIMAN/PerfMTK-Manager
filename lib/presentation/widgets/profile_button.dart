import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/presentation/widgets/profile_utils.dart';

class ProfileButton extends StatefulWidget {
  final ProfileType profile;
  final bool isSelected;
  final VoidCallback onTap;

  const ProfileButton({
    super.key,
    required this.profile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.animationNormal,
      vsync: this,
      value: widget.isSelected ? 1.0 : 0.0,
    );
    _fillAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(ProfileButton old) {
    super.didUpdateWidget(old);
    if (widget.isSelected != old.isSelected) {
      widget.isSelected ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = ProfileUtils.colorFor(widget.profile);
    final icon = ProfileUtils.iconFor(widget.profile);
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: '${widget.profile.displayName} profile',
      child: AnimatedBuilder(
        animation: _fillAnimation,
        builder: (context, child) {
          final t = _fillAnimation.value;
          final borderColor = Color.lerp(
            theme.colorScheme.outlineVariant,
            color,
            t,
          )!;
          final bgColor = Color.lerp(
            theme.colorScheme.surface,
            color.withValues(alpha: 0.08),
            t,
          )!;

          return Material(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            child: InkWell(
              onTap: widget.isSelected
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      widget.onTap();
                    },
              borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
              splashColor: color.withValues(alpha: 0.15),
              highlightColor: color.withValues(alpha: 0.08),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing20,
                  vertical: AppConstants.spacing16,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusXLarge),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: t > 0
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.15 * t),
                            blurRadius: 16 * t,
                            spreadRadius: 2 * t,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Icon container
                    AnimatedContainer(
                      duration: AppConstants.animationNormal,
                      padding: const EdgeInsets.all(AppConstants.spacing12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1 + 0.08 * t),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                      child: Icon(icon, color: color, size: AppConstants.iconSizeLarge),
                    ),
                    const SizedBox(width: AppConstants.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: AppConstants.animationFast,
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Color.lerp(
                                theme.colorScheme.onSurface,
                                color,
                                t,
                              ),
                            ),
                            child: Text(widget.profile.displayName),
                          ),
                          const SizedBox(height: AppConstants.spacing4),
                          Text(
                            _descriptionFor(context),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Checkmark
                    AnimatedOpacity(
                      duration: AppConstants.animationFast,
                      opacity: _fillAnimation.value,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: color,
                        size: AppConstants.iconSizeNormal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _descriptionFor(BuildContext context) {
    switch (widget.profile) {
      case ProfileType.performance:
        return AppLocale.performanceDesc.getString(context);
      case ProfileType.balanced:
        return AppLocale.balancedDesc.getString(context);
      case ProfileType.powersave:
        return AppLocale.powersaveDesc.getString(context);
      case ProfileType.powersavePlus:
        return AppLocale.powersavePlusDesc.getString(context);
    }
  }
}