import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager/config/app_constants.dart';

class AppTheme {
  // ── Paleta ─────────────────────────────────────────────────────────────────
  static const Color _primary = Color(0xFF2D7DD2);
  static const Color _primaryDark = Color(0xFF5BA4FF);
  static const Color _secondary = Color(0xFF34C77B);

  // Light surfaces
  static const Color _lightBg = Color(0xFFF4F6FA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceVariant = Color(0xFFEDF0F7);

  // Dark surfaces
  static const Color _darkBg = Color(0xFF0D0D0F);
  static const Color _darkSurface = Color(0xFF161618);
  static const Color _darkSurfaceVariant = Color(0xFF1E1E22);
  static const Color _darkSurfaceHighest = Color(0xFF252528);

  static ThemeMode get themeMode => ThemeMode.system;

  // ── Tipografía ─────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color onSurface) {
    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w700, letterSpacing: -1.5),
        displayMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        displaySmall: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        headlineLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w700, letterSpacing: -0.25),
        titleMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w600, letterSpacing: 0),
        titleSmall: TextStyle(color: onSurface, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        bodyLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w400, letterSpacing: 0.1),
        bodyMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w400, letterSpacing: 0.25),
        bodySmall: TextStyle(color: onSurface, fontWeight: FontWeight.w400, letterSpacing: 0.4),
        labelLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        labelMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        labelSmall: TextStyle(color: onSurface, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      ),
    );
  }

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: _primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD6E8FF),
      onPrimaryContainer: const Color(0xFF00325A),
      secondary: _secondary,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFB7F5D5),
      onSecondaryContainer: const Color(0xFF002114),
      tertiary: const Color(0xFF8B5CF6),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFEDE9FE),
      onTertiaryContainer: const Color(0xFF2E0066),
      error: const Color(0xFFE53935),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: _lightSurface,
      onSurface: const Color(0xFF1A1C22),
      surfaceContainerLowest: _lightSurface,
      surfaceContainerLow: const Color(0xFFF9FAFB),
      surfaceContainer: _lightSurfaceVariant,
      surfaceContainerHigh: const Color(0xFFE5E8F0),
      surfaceContainerHighest: const Color(0xFFDDE1EA),
      onSurfaceVariant: const Color(0xFF44474F),
      outline: const Color(0xFF74777F),
      outlineVariant: const Color(0xFFC4C7D0),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFF2F3138),
      onInverseSurface: const Color(0xFFF1F0F7),
      inversePrimary: const Color(0xFFAAC8FF),
    ),
    scaffoldBackgroundColor: _lightBg,
    textTheme: _buildTextTheme(const Color(0xFF1A1C22)),

    // App Bar — distinct primary-tinted header
    appBarTheme: AppBarTheme(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppConstants.radiusMedium),
        ),
      ),
    ),

    // Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      backgroundColor: _lightSurface.withValues(alpha: 0.92),
      surfaceTintColor: Colors.transparent,
      indicatorColor: _primary.withValues(alpha: 0.12),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          color: selected ? _primary : const Color(0xFF74777F),
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          letterSpacing: 0.3,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected)
              ? _primary
              : const Color(0xFF74777F),
          size: states.contains(WidgetState.selected) ? 24 : 22,
        );
      }),
    ),

    // Card
    cardTheme: CardThemeData(
      elevation: 0,
      color: _lightSurface,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        side: const BorderSide(color: Color(0xFFE5E8F0), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFE5E8F0),
        disabledForegroundColor: const Color(0xFF74777F),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primary,
        side: BorderSide(color: _primary.withValues(alpha: 0.5), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // FAB
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFE5E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFE5E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFE53935)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
      ),
      hintStyle: GoogleFonts.inter(color: const Color(0xFF9EA3B0), fontSize: 14),
      labelStyle: GoogleFonts.inter(color: const Color(0xFF44474F), fontSize: 14, fontWeight: FontWeight.w500),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: _lightSurfaceVariant,
      selectedColor: _primary,
      disabledColor: const Color(0xFFE5E8F0),
      labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: _lightSurface,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXXLarge),
      ),
      titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1A1C22)),
      contentTextStyle: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF44474F), height: 1.6),
    ),

    // Bottom Sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _lightSurface,
      elevation: 8,
      modalElevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXXLarge)),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1E2128),
      contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      actionTextColor: _secondary,
      behavior: SnackBarBehavior.floating,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : const Color(0xFF9EA3B0),
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? _secondary : const Color(0xFFDDE1EA),
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E8F0),
      thickness: 1,
      space: 1,
    ),

    // Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: _primary,
      inactiveTrackColor: _primary.withValues(alpha: 0.15),
      thumbColor: _primary,
      overlayColor: _primary.withValues(alpha: 0.12),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
    ),
  );

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: _primaryDark,
      onPrimary: const Color(0xFF00325A),
      primaryContainer: const Color(0xFF00497D),
      onPrimaryContainer: const Color(0xFFD6E8FF),
      secondary: _secondary,
      onSecondary: const Color(0xFF002114),
      secondaryContainer: const Color(0xFF005233),
      onSecondaryContainer: const Color(0xFFB7F5D5),
      tertiary: const Color(0xFFCFB8FF),
      onTertiary: const Color(0xFF2E0066),
      tertiaryContainer: const Color(0xFF44009B),
      onTertiaryContainer: const Color(0xFFEDE9FE),
      error: const Color(0xFFFF6B6B),
      onError: const Color(0xFF410002),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: _darkSurface,
      onSurface: const Color(0xFFE4E2EC),
      surfaceContainerLowest: _darkBg,
      surfaceContainerLow: const Color(0xFF1A1A1E),
      surfaceContainer: _darkSurfaceVariant,
      surfaceContainerHigh: const Color(0xFF222226),
      surfaceContainerHighest: _darkSurfaceHighest,
      onSurfaceVariant: const Color(0xFFA8AABC),
      outline: const Color(0xFF52545E),
      outlineVariant: const Color(0xFF30313A),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFFE4E2EC),
      onInverseSurface: const Color(0xFF2F3138),
      inversePrimary: _primary,
    ),
    scaffoldBackgroundColor: _darkBg,
    textTheme: _buildTextTheme(const Color(0xFFE4E2EC)),

    // App Bar — dark variant with a slightly lighter primary shade
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0F2744),
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppConstants.radiusMedium),
        ),
      ),
    ),

    // Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      backgroundColor: _darkSurface.withValues(alpha: 0.92),
      surfaceTintColor: Colors.transparent,
      indicatorColor: _primaryDark.withValues(alpha: 0.18),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          color: selected ? _primaryDark : const Color(0xFF74777F),
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          letterSpacing: 0.3,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected)
              ? _primaryDark
              : const Color(0xFF74777F),
          size: states.contains(WidgetState.selected) ? 24 : 22,
        );
      }),
    ),

    // Card
    cardTheme: CardThemeData(
      elevation: 0,
      color: _darkSurfaceVariant,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: _primaryDark,
        foregroundColor: const Color(0xFF00325A),
        disabledBackgroundColor: _darkSurfaceHighest,
        disabledForegroundColor: const Color(0xFF52545E),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryDark,
        side: BorderSide(color: _primaryDark.withValues(alpha: 0.5), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // FAB
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryDark,
      foregroundColor: const Color(0xFF00325A),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: const BorderSide(color: _primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
      ),
      hintStyle: GoogleFonts.inter(color: const Color(0xFF52545E), fontSize: 14),
      labelStyle: GoogleFonts.inter(color: const Color(0xFFA8AABC), fontSize: 14, fontWeight: FontWeight.w500),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: _darkSurfaceHighest,
      selectedColor: _primaryDark,
      disabledColor: _darkSurfaceVariant,
      labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: _darkSurfaceVariant,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXXLarge),
      ),
      titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFFE4E2EC)),
      contentTextStyle: GoogleFonts.inter(fontSize: 15, color: const Color(0xFFA8AABC), height: 1.6),
    ),

    // Bottom Sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: _darkSurfaceVariant,
      elevation: 8,
      modalElevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXXLarge)),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFFE4E2EC),
      contentTextStyle: GoogleFonts.inter(color: const Color(0xFF1A1C22), fontSize: 14, fontWeight: FontWeight.w500),
      actionTextColor: _secondary,
      behavior: SnackBarBehavior.floating,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? const Color(0xFF00325A) : const Color(0xFF52545E),
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? _secondary : _darkSurfaceHighest,
      ),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.07),
      thickness: 1,
      space: 1,
    ),

    // Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: _primaryDark,
      inactiveTrackColor: _primaryDark.withValues(alpha: 0.18),
      thumbColor: _primaryDark,
      overlayColor: _primaryDark.withValues(alpha: 0.15),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
    ),
  );
}