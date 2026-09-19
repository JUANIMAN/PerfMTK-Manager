import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/data/models/profile.dart';
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
  bool _isPressed = false;

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = ProfileUtils.colorFor(widget.profile, isDark: isDark);
    final icon = ProfileUtils.iconFor(widget.profile);

    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: ProfileUtils.nameFor(context, widget.profile),
      child: AnimatedBuilder(
        animation: _fillAnimation,
        builder: (context, child) {
          final t = _fillAnimation.value;
          final borderColor = Color.lerp(
            theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
            color.withValues(alpha: 0.50),
            t,
          )!;
          final bgColor = Color.lerp(
            theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
            color.withValues(alpha: isDark ? 0.20 : 0.12),
            t,
          )!;

          return AnimatedScale(
            scale: _isPressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutQuad,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: t > 0.05
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.16 * t),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTapDown: (_) {
                    if (!widget.isSelected) {
                      setState(() => _isPressed = true);
                    }
                  },
                  onTapUp: (_) {
                    if (_isPressed) {
                      setState(() => _isPressed = false);
                    }
                  },
                  onTapCancel: () {
                    if (_isPressed) {
                      setState(() => _isPressed = false);
                    }
                  },
                  onTap: widget.isSelected
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          widget.onTap();
                        },
                  borderRadius: BorderRadius.circular(20),
                  splashColor: color.withValues(alpha: 0.15),
                  highlightColor: color.withValues(alpha: 0.08),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: borderColor,
                        width: 1.0 + 0.5 * t,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: color.withValues(
                              alpha: isDark ? 0.22 : 0.14,
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            icon,
                            color: color,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _shortNameFor(context),
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                        color: widget.isSelected
                                            ? color
                                            : theme.colorScheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.isSelected) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: color,
                                      size: 15,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _tagFor(context),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: widget.isSelected
                                      ? color.withValues(alpha: 0.8)
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _shortNameFor(BuildContext context) =>
      ProfileUtils.cardNameFor(context, widget.profile);

  String _tagFor(BuildContext context) =>
      ProfileUtils.tagFor(context, widget.profile);
}
