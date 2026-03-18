import 'package:flutter/material.dart';

/// Constantes
class AppConstants {
  // Espaciado
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Border radius
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;
  static const double radiusXXLarge = 28.0;

  // Elevaciones
  static const double elevationNone = 0.0;
  static const double elevationSmall = 1.0;
  static const double elevationMedium = 3.0;
  static const double elevationLarge = 8.0;

  // Tamaños de iconos
  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeNormal = 24.0;
  static const double iconSizeLarge = 26.0;
  static const double iconSizeXLarge = 32.0;
  static const double iconSizeXXLarge = 48.0;

  // Opacidades
  static const double opacityDisabled = 0.5;
  static const double opacitySubtle = 0.7;
  static const double opacityLight = 0.1;
  static const double opacityMedium = 0.15;
  static const double opacityBorder = 0.2;
  static const double opacityShadow = 0.05;

  // Duración de animaciones
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 400);

  // Padding
  static const EdgeInsets paddingSmall = EdgeInsets.all(spacing8);
  static const EdgeInsets paddingMedium = EdgeInsets.all(spacing12);
  static const EdgeInsets paddingNormal = EdgeInsets.all(spacing16);
  static const EdgeInsets paddingLarge = EdgeInsets.all(spacing24);

  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: spacing16);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: spacing16);

  // Margin
  static const EdgeInsets marginSmall = EdgeInsets.all(spacing8);
  static const EdgeInsets marginBottom = EdgeInsets.only(bottom: spacing12);
  static const EdgeInsets marginBottomLarge = EdgeInsets.only(bottom: spacing80);

  static const double spacing80 = 80.0;
}

/// Extension methods para aplicar opacidad
extension ColorOpacity on Color {
  Color get disabled => withValues(alpha: AppConstants.opacityDisabled);
  Color get subtle => withValues(alpha: AppConstants.opacitySubtle);
  Color get light => withValues(alpha: AppConstants.opacityLight);
  Color get medium => withValues(alpha: AppConstants.opacityMedium);
  Color get border => withValues(alpha: AppConstants.opacityBorder);
  Color get shadow => withValues(alpha: AppConstants.opacityShadow);
}

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

/// Mixin para animaciones de entrada
mixin EntryAnimationMixin<T extends StatefulWidget> on State<T>, SingleTickerProviderStateMixin<T> {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  late Animation<Offset> slideAnimation;

  void initEntryAnimation({
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
  }) {
    animationController = AnimationController(
      duration: duration,
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: curve),
    );

    animationController.forward();
  }

  void disposeEntryAnimation() {
    animationController.dispose();
  }

  Widget buildWithEntryAnimation(Widget child) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, _) => FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: Transform.scale(
            scale: scaleAnimation.value,
            child: child,
          ),
        ),
      ),
    );
  }
}