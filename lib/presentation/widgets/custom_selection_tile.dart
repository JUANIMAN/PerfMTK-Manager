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
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final accentColor = iconColor ?? colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: 4.5,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: accentColor.withValues(alpha: 0.12),
          highlightColor: accentColor.withValues(alpha: 0.06),
          child: AnimatedContainer(
            duration: AppConstants.animationFast,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing16,
              vertical: AppConstants.spacing12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(alpha: isDark ? 0.14 : 0.08)
                  : (isDark
                      ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.35)
                      : colorScheme.surfaceContainer.withValues(alpha: 0.45)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? accentColor.withValues(alpha: isDark ? 0.55 : 0.45)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06)),
                width: isSelected ? 1.2 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withValues(alpha: isDark ? 0.15 : 0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Icon or text (emoji)
                if (icon != null || iconText != null) ...[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isSelected ? 0.20 : 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: icon != null
                          ? Icon(
                              icon,
                              color: isSelected
                                  ? accentColor
                                  : (isDark
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onSurface.withValues(alpha: 0.75)),
                              size: 22,
                            )
                          : Text(
                              iconText!,
                              style: const TextStyle(fontSize: 20),
                            ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing14),
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
                          color: isSelected
                              ? accentColor
                              : colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: isDark ? 0.75 : 0.85,
                            ),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: AppConstants.spacing12),

                // Checkmark capsule / radio
                AnimatedSwitcher(
                  duration: AppConstants.animationFast,
                  child: isSelected
                      ? Container(
                          key: const ValueKey('checked'),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.35),
                                blurRadius: 6,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        )
                      : Container(
                          key: const ValueKey('unchecked'),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? colorScheme.outlineVariant.withValues(alpha: 0.5)
                                  : colorScheme.outline.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
