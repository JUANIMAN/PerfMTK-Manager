import 'package:flutter/material.dart';

/// Constantes
class AppConstants {
  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing28 = 28.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;

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
