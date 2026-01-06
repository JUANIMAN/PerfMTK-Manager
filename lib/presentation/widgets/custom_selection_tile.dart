import 'package:flutter/material.dart';
import 'package:manager/config/app_constants.dart';

class SelectionTile extends StatelessWidget {
  final IconData? icon;
  final String? iconText;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionTile({
    super.key,
    this.icon,
    this.iconText,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final accentColor = iconColor ?? colorScheme.primary;

    final backgroundColor = isSelected
        ? accentColor.light
        : colorScheme.surfaceContainerHigh;

    final foregroundColor = isSelected
        ? accentColor
        : (iconColor ?? colorScheme.onSurfaceVariant);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
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
              // Icono o texto del icono
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: icon != null
                    ? Icon(
                        icon,
                        color: foregroundColor,
                        size: AppConstants.iconSizeNormal,
                      )
                    : Text(
                        iconText ?? '',
                        style: const TextStyle(fontSize: 24),
                      ),
              ),
              const SizedBox(width: AppConstants.spacing16),

              // Título y subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? accentColor : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Checkmark si está seleccionado
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: accentColor,
                  size: AppConstants.iconSizeNormal,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
