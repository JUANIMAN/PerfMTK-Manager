import 'package:flutter/material.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/features/system/data/models/profile.dart';
import 'package:manager/l10n/l10n.dart';

/// Utilidad centralizada para propiedades visuales de perfiles.
/// Elimina la lógica duplicada que existía en 5+ widgets.
abstract final class ProfileUtils {
  static String nameFor(BuildContext context, ProfileType profile) {
    final l = context.l10n;
    return switch (profile) {
      ProfileType.performance => l.performance,
      ProfileType.balanced => l.balanced,
      ProfileType.powersave => l.powersave,
      ProfileType.powersavePlus => l.powersavePlus,
    };
  }

  static String shortNameFor(BuildContext context, ProfileType profile) {
    final l = context.l10n;
    return switch (profile) {
      ProfileType.performance => l.tabPerf,
      ProfileType.balanced => l.tabBalanced,
      ProfileType.powersave => l.tabPowersave,
      ProfileType.powersavePlus => l.tabPowersavePlus,
    };
  }

  static String cardNameFor(BuildContext context, ProfileType profile) {
    final l = context.l10n;
    return switch (profile) {
      ProfileType.performance => l.cardPerformance,
      ProfileType.balanced => l.cardBalanced,
      ProfileType.powersave => l.cardPowersave,
      ProfileType.powersavePlus => l.cardPowersavePlus,
    };
  }

  static String tagFor(BuildContext context, ProfileType profile) {
    final l = context.l10n;
    return switch (profile) {
      ProfileType.performance => l.cardTagPerformance,
      ProfileType.balanced => l.cardTagBalanced,
      ProfileType.powersave => l.cardTagPowersave,
      ProfileType.powersavePlus => l.cardTagPowersavePlus,
    };
  }

  // -- Color (resolved from the PerfColors theme extension) -----------------
  static Color colorFor(ProfileType? profile, {bool isDark = true}) =>
      (isDark ? PerfColors.dark : PerfColors.light).profile(profile);

  static Color colorForContext(BuildContext context, ProfileType? profile) =>
      context.perfColors.profile(profile);

  // -- Icon -----------------------------------------------------------------
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

  // -- Gradient -------------------------------------------------------------
  static List<Color> gradientFor(ProfileType? profile, {bool isDark = true}) =>
      (isDark ? PerfColors.dark : PerfColors.light).profileGradient(
        profile,
        isDark: isDark,
      );
}