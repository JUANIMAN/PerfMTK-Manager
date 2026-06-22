import 'package:flutter/material.dart';
import 'package:manager/data/models/profile.dart';

/// Utilidad centralizada para propiedades visuales de perfiles.
/// Elimina la lógica duplicada que existía en 5+ widgets.
abstract final class ProfileUtils {
  // ── Color ─────────────────────────────────────────────────────────────────
  static Color colorFor(ProfileType? profile) {
    switch (profile) {
      case ProfileType.performance:
        return const Color(0xFFFF6B35);
      case ProfileType.balanced:
        return const Color(0xFF4A9EFF);
      case ProfileType.powersave:
        return const Color(0xFF34C77B);
      case ProfileType.powersavePlus:
        return const Color(0xFF00B4A6);
      case null:
        return const Color(0xFF8E99A4);
    }
  }

  // ── Icon ──────────────────────────────────────────────────────────────────
  static IconData iconFor(ProfileType? profile) {
    switch (profile) {
      case ProfileType.performance:
        return Icons.bolt_rounded;
      case ProfileType.balanced:
        return Icons.balance_rounded;
      case ProfileType.powersave:
        return Icons.battery_charging_full_rounded;
      case ProfileType.powersavePlus:
        return Icons.eco_rounded;
      case null:
        return Icons.settings_applications_rounded;
    }
  }

  // ── Gradient ──────────────────────────────────────────────────────────────
  static List<Color> gradientFor(ProfileType? profile) {
    final base = colorFor(profile);
    switch (profile) {
      case ProfileType.performance:
        return [const Color(0xFFFF6B35), const Color(0xFFFF3B00)];
      case ProfileType.balanced:
        return [const Color(0xFF4A9EFF), const Color(0xFF1A6FD4)];
      case ProfileType.powersave:
        return [const Color(0xFF34C77B), const Color(0xFF1A9A58)];
      case ProfileType.powersavePlus:
        return [const Color(0xFF00B4A6), const Color(0xFF007A70)];
      case null:
        return [base, base.withValues(alpha: 0.7)];
    }
  }
}
