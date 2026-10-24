import 'package:flutter/material.dart';
import 'package:manager/core/design/app_palette.dart';
import 'package:manager/features/system/data/models/profile.dart';

/// Semantic, theme-aware colors for PerfMTK widgets.
///
/// Resolve once with `context.perfColors` instead of branching on
/// `Brightness.dark` at every call site.
@immutable
class PerfColors extends ThemeExtension<PerfColors> {
  const PerfColors({
    required this.accent,
    required this.live,
    required this.warm,
    required this.hot,
    required this.engine,
    required this.clusterLittle,
    required this.clusterMid,
    required this.clusterPrime,
    required this.glassFill,
    required this.glassBorder,
    required this.navIdle,
    required this.performance,
    required this.balanced,
    required this.powersave,
    required this.powersavePlus,
    required this.noProfile,
    required this.performanceEnd,
    required this.balancedEnd,
    required this.powersaveEnd,
    required this.powersavePlusEnd,
  });

  /// Selected / informational blue.
  final Color accent;

  /// Healthy telemetry (temps OK, live indicators).
  final Color live;

  /// Warning tone (warm temps, bypass active).
  final Color warm;

  /// Critical tone (hot temps).
  final Color hot;

  /// Foreground-engine badge.
  final Color engine;

  final Color clusterLittle;
  final Color clusterMid;
  final Color clusterPrime;

  /// Frosted floating bar (navigation, FAB) fill and border.
  final Color glassFill;
  final Color glassBorder;

  /// Unselected navigation icon.
  final Color navIdle;

  final Color performance;
  final Color balanced;
  final Color powersave;
  final Color powersavePlus;
  final Color noProfile;

  /// Gradient end tones (the start of each gradient is the profile color).
  final Color performanceEnd;
  final Color balancedEnd;
  final Color powersaveEnd;
  final Color powersavePlusEnd;

  static const PerfColors dark = PerfColors(
    accent: AppPalette.sky400,
    live: AppPalette.emerald500,
    warm: AppPalette.amber500,
    hot: AppPalette.red500,
    engine: AppPalette.neonGreen,
    clusterLittle: AppPalette.sky400,
    clusterMid: AppPalette.blue400,
    clusterPrime: AppPalette.indigo400,
    glassFill: Color(0xA6161618), // ink900 @ 65%
    glassBorder: Color(0x29FFFFFF), // white @ 16%
    navIdle: Color(0x99A8AABC), // dark onSurfaceVariant @ 60%
    performance: Color(0xFFFF6B35),
    balanced: Color(0xFF4A9EFF),
    powersave: Color(0xFF34C77B),
    powersavePlus: Color(0xFF00B4A6),
    noProfile: Color(0xFF8E99A4),
    performanceEnd: Color(0xFFFF3B00),
    balancedEnd: Color(0xFF1A6FD4),
    powersaveEnd: Color(0xFF1A9A58),
    powersavePlusEnd: Color(0xFF007A70),
  );

  static const PerfColors light = PerfColors(
    accent: AppPalette.blue600,
    live: AppPalette.emerald600,
    warm: AppPalette.amber600,
    hot: AppPalette.red600,
    engine: AppPalette.engineLight,
    clusterLittle: AppPalette.sky600,
    clusterMid: AppPalette.blue600,
    clusterPrime: AppPalette.indigo600,
    glassFill: Color(0xD9FFFFFF), // white @ 85%
    glassBorder: Color(0x14000000), // black @ 8%
    navIdle: Color(0xBF334155), // slate700 @ 75%
    performance: Color(0xFFEA580C),
    balanced: Color(0xFF2563EB),
    powersave: Color(0xFF16A34A),
    powersavePlus: Color(0xFF0D9488),
    noProfile: AppPalette.slate500,
    performanceEnd: Color(0xFFEA580C),
    balancedEnd: Color(0xFF2563EB),
    powersaveEnd: Color(0xFF16A34A),
    powersavePlusEnd: Color(0xFF0D9488),
  );

  /// Accent color of a performance profile (`null` = no profile selected).
  Color profile(ProfileType? type) => switch (type) {
    ProfileType.performance => performance,
    ProfileType.balanced => balanced,
    ProfileType.powersave => powersave,
    ProfileType.powersavePlus => powersavePlus,
    null => noProfile,
  };

  /// Two-stop gradient for a profile. Light theme fades the base color;
  /// dark theme goes to a deeper tone.
  List<Color> profileGradient(ProfileType? type, {required bool isDark}) {
    final base = profile(type);
    if (!isDark) return [base, base.withValues(alpha: 0.85)];
    return switch (type) {
      ProfileType.performance => [base, performanceEnd],
      ProfileType.balanced => [base, balancedEnd],
      ProfileType.powersave => [base, powersaveEnd],
      ProfileType.powersavePlus => [base, powersavePlusEnd],
      null => [base, base.withValues(alpha: 0.7)],
    };
  }

  /// CPU cluster color by index (little → mid → prime).
  Color cluster(int index) => switch (index) {
    0 => clusterLittle,
    1 => clusterMid,
    _ => clusterPrime,
  };

  /// CPU cluster accent when a SoC exposes [total] clusters (2 or 3 usually).
  Color clusterAccent(int index, int total) {
    if (total == 3) return cluster(index);
    if (total == 2) return index == 0 ? clusterLittle : clusterPrime;
    return accent;
  }

  /// Temperature severity color (Â°C).
  Color tempColor(double celsius) {
    if (celsius >= 70.0) return hot;
    if (celsius >= 55.0) return warm;
    return live;
  }

  /// Severity color for segment [index] of a thermal LED meter.
  Color thermalSegment(int index) {
    if (index >= 5) return hot;
    if (index >= 3) return warm;
    return live;
  }

  @override
  PerfColors copyWith({
    Color? accent,
    Color? live,
    Color? warm,
    Color? hot,
    Color? engine,
    Color? clusterLittle,
    Color? clusterMid,
    Color? clusterPrime,
    Color? glassFill,
    Color? glassBorder,
    Color? navIdle,
    Color? performance,
    Color? balanced,
    Color? powersave,
    Color? powersavePlus,
    Color? noProfile,
    Color? performanceEnd,
    Color? balancedEnd,
    Color? powersaveEnd,
    Color? powersavePlusEnd,
  }) {
    return PerfColors(
      accent: accent ?? this.accent,
      live: live ?? this.live,
      warm: warm ?? this.warm,
      hot: hot ?? this.hot,
      engine: engine ?? this.engine,
      clusterLittle: clusterLittle ?? this.clusterLittle,
      clusterMid: clusterMid ?? this.clusterMid,
      clusterPrime: clusterPrime ?? this.clusterPrime,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      navIdle: navIdle ?? this.navIdle,
      performance: performance ?? this.performance,
      balanced: balanced ?? this.balanced,
      powersave: powersave ?? this.powersave,
      powersavePlus: powersavePlus ?? this.powersavePlus,
      noProfile: noProfile ?? this.noProfile,
      performanceEnd: performanceEnd ?? this.performanceEnd,
      balancedEnd: balancedEnd ?? this.balancedEnd,
      powersaveEnd: powersaveEnd ?? this.powersaveEnd,
      powersavePlusEnd: powersavePlusEnd ?? this.powersavePlusEnd,
    );
  }

  @override
  PerfColors lerp(ThemeExtension<PerfColors>? other, double t) {
    if (other is! PerfColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return PerfColors(
      accent: l(accent, other.accent),
      live: l(live, other.live),
      warm: l(warm, other.warm),
      hot: l(hot, other.hot),
      engine: l(engine, other.engine),
      clusterLittle: l(clusterLittle, other.clusterLittle),
      clusterMid: l(clusterMid, other.clusterMid),
      clusterPrime: l(clusterPrime, other.clusterPrime),
      glassFill: l(glassFill, other.glassFill),
      glassBorder: l(glassBorder, other.glassBorder),
      navIdle: l(navIdle, other.navIdle),
      performance: l(performance, other.performance),
      balanced: l(balanced, other.balanced),
      powersave: l(powersave, other.powersave),
      powersavePlus: l(powersavePlus, other.powersavePlus),
      noProfile: l(noProfile, other.noProfile),
      performanceEnd: l(performanceEnd, other.performanceEnd),
      balancedEnd: l(balancedEnd, other.balancedEnd),
      powersaveEnd: l(powersaveEnd, other.powersaveEnd),
      powersavePlusEnd: l(powersavePlusEnd, other.powersavePlusEnd),
    );
  }
}

extension PerfColorsContext on BuildContext {
  /// Semantic colors for the active theme (falls back to dark/light by brightness).
  PerfColors get perfColors {
    final theme = Theme.of(this);
    return theme.extension<PerfColors>() ??
        (theme.brightness == Brightness.dark
            ? PerfColors.dark
            : PerfColors.light);
  }

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
