import 'package:flutter/material.dart';
import 'package:manager/config/app_constants.dart';

class SelectionTile extends StatelessWidget {
  final IconData? icon;
  final String? iconText;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionTile({
    super.key,
    this.icon,
    this.iconText,
    this.iconColor,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = iconColor ?? colorScheme.primary;

    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: accentColor.withValues(alpha: 0.12),
          highlightColor: accentColor.withValues(alpha: 0.06),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing16,
              vertical: AppConstants.spacing12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.light
                  : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isSelected ? accentColor : Colors.transparent,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                // Icon or text (emoji)
                if (icon != null || iconText != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacing10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isSelected ? 0.18 : 0.14),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: icon != null
                        ? Icon(
                            icon,
                            color: isSelected ? accentColor : colorScheme.onSurfaceVariant,
                            size: AppConstants.iconSizeNormal,
                          )
                        : Text(
                            iconText!,
                            style: const TextStyle(fontSize: 20),
                          ),
                  ),
                  const SizedBox(width: AppConstants.spacing16),
                ],

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isSelected ? accentColor : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: AppConstants.spacing16),

                // Checkmark or unchecked circle
                AnimatedSwitcher(
                  duration: AppConstants.animationFast,
                  child: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey('checked'),
                          color: accentColor,
                          size: AppConstants.iconSizeNormal,
                        )
                      : Icon(
                          Icons.radio_button_unchecked_rounded,
                          key: const ValueKey('unchecked'),
                          color: colorScheme.outlineVariant,
                          size: AppConstants.iconSizeNormal,
                        ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
