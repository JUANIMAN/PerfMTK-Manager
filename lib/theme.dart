import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF3D46F2);
  static const _primaryVariantColor = Color(0xFF636AF2);
  static const _secondaryColor = Color(0xFF03DAC6);
  static const _secondaryVariantColor = Color(0xFF018786);
  static const _lightBackgroundColor = Color(0xFFFAFAFA);
  static const _darkBackgroundColor = Color(0xFF121212);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _primaryColor,
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      primaryContainer: _primaryVariantColor,
      secondary: _secondaryColor,
      secondaryContainer: _secondaryVariantColor,
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
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 24),
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
    textTheme: TextTheme(
      displayLarge: const TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 32),
      displayMedium: const TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 28),
      displaySmall: const TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 24),
      headlineMedium: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 20),
      bodyLarge: const TextStyle(color: Colors.black87, fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(color: Colors.black.withOpacity(0.75), fontSize: 14, height: 1.5),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.black.withOpacity(0.1),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1,
      space: 32,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _primaryColor,
    colorScheme: ColorScheme.dark(
      primary: _primaryColor,
      primaryContainer: _primaryVariantColor,
      secondary: _secondaryColor,
      secondaryContainer: _secondaryVariantColor,
      surface: const Color(0xFF1E1E1E),
      error: Colors.red.shade300,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: _darkBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: _secondaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(color: _secondaryColor, fontWeight: FontWeight.bold, fontSize: 20),
      iconTheme: const IconThemeData(color: _secondaryColor),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[900],
      selectedItemColor: _secondaryColor,
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 24),
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
    textTheme: TextTheme(
      displayLarge: const TextStyle(color: _secondaryColor, fontWeight: FontWeight.bold, fontSize: 32),
      displayMedium: const TextStyle(color: _secondaryColor, fontWeight: FontWeight.bold, fontSize: 28),
      displaySmall: const TextStyle(color: _secondaryColor, fontWeight: FontWeight.bold, fontSize: 24),
      headlineMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
      bodyLarge: TextStyle(color: Colors.grey[300]!, fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(color: Colors.grey[400]!, fontSize: 14, height: 1.5),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF2C2C2C),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _secondaryColor, width: 2),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[700],
      thickness: 1,
      space: 32,
    ),
  );
}
