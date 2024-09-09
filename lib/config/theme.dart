import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF0460D9);
  static const _secondaryColor = Color(0xFF5BD96E);
  static const _lightBackgroundColor = Color(0xFFF2F2F2);
  static const _darkBackgroundColor = Color(0xFF121212);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _primaryColor,
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      secondary: _secondaryColor,
      surface: Colors.white,
      error: Colors.red.shade400,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black87,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: _lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: _secondaryColor,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);
        }
        return const TextStyle(color: Colors.black54, fontSize: 14);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.white, size: 24);
        }
        return const IconThemeData(color: Colors.black54, size: 24);
      }),
      backgroundColor: Colors.white,
      elevation: 8,
      height: 70,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _primaryColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 32),
      displayMedium: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 28),
      displaySmall: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 24),
      headlineMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 20),
      bodyLarge: TextStyle(color: Colors.black87, fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF262626),
      contentTextStyle: const TextStyle(color: Colors.white),
      actionTextColor: _secondaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _primaryColor,
    colorScheme: ColorScheme.dark(
      primary: _primaryColor,
      secondary: _secondaryColor,
      surface: const Color(0xFF1E1E1E),
      error: Colors.red.shade300,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: _darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF262626),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: _secondaryColor,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);
        }
        return const TextStyle(color: Colors.white70, fontSize: 14);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.black, size: 24);
        }
        return const IconThemeData(color: Colors.white70, size: 24);
      }),
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 8,
      height: 70,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _primaryColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF262626),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: _secondaryColor, fontWeight: FontWeight.bold, fontSize: 32),
      displayMedium: TextStyle(color: _secondaryColor, fontWeight: FontWeight.bold, fontSize: 28),
      displaySmall: TextStyle(color: _secondaryColor, fontWeight: FontWeight.bold, fontSize: 24),
      headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
      bodyLarge: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFFF2F2F2),
      contentTextStyle: const TextStyle(color: Colors.black),
      actionTextColor: _secondaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
