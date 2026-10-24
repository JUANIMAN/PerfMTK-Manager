import 'package:flutter/material.dart';
import 'package:manager/core/design/tokens.dart';

/// Widget base para Cards
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.borderColor,
    this.elevation,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation ?? AppConstants.elevationNone,
      margin: margin ?? AppConstants.marginBottom,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        side: BorderSide(
          color: borderColor ?? Theme.of(context).dividerColor.light,
          width: 1,
        ),
      ),
      child: Padding(
        padding: padding ?? AppConstants.paddingNormal,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: card,
      );
    }

    return card;
  }
}

/// Widget para contenedor de íconos
class IconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double? size;
  final double? iconSize;

  const IconContainer({
    super.key,
    required this.icon,
    required this.color,
    this.size,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size ?? AppConstants.spacing12),
      decoration: BoxDecoration(
        color: color.light,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(
          color: color.border,
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: iconSize ?? AppConstants.iconSizeNormal,
      ),
    );
  }
}

/// Widget para secciones con header
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppConstants.spacing4),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.spacing8),
              ),
              child: Icon(
                icon,
                size: AppConstants.iconSizeSmall,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppConstants.spacing12),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
