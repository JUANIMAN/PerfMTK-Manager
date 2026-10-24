import 'package:flutter/material.dart';

/// Raw color values. This is the only place (besides the Material color
/// schemes in `theme.dart`) where color literals should appear; widgets use
/// either these named constants or the semantic roles in `PerfColors`.
abstract final class AppPalette {
  // Neon accents shared by both themes (directive / metric highlights).
  static const Color neonGreen = Color(0xFF00E676);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonOrange = Color(0xFFFF6D00);
  static const Color neonRed = Color(0xFFFF5252);
  static const Color neonAmber = Color(0xFFFFB300);
  static const Color neonPurple = Color(0xFFE040FB);
  static const Color neonTeal = Color(0xFF26A69A);
  static const Color vividOrange = Color(0xFFFF9100);
  static const Color amber = Color(0xFFFFC107);
  static const Color amberAccent = Color(0xFFFFAB00);
  static const Color purple = Color(0xFFD500F9);
  static const Color blueAccent = Color(0xFF2979FF);
  static const Color skyAccent = Color(0xFF00B0FF);

  // Theme-paired tones (dark / light), consumed through PerfColors.
  static const Color sky400 = Color(0xFF38BDF8);
  static const Color sky600 = Color(0xFF0284C7);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color engineLight = Color(0xFF0A8754);

  // Slate neutrals.
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);

  // Dark surfaces.
  static const Color ink900 = Color(0xFF161618);
  static const Color navy900 = Color(0xFF161F30);
}
