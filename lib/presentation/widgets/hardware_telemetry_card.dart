import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/localization/app_locales.dart';

/// Cyber-Engine Unified Hardware Telemetry HUD with multi-segment LED rev meters.
class HardwareTelemetryCard extends StatelessWidget {
  final SystemState state;

  const HardwareTelemetryCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB);
    final liveColor = isDark ? const Color(0xFF10B981) : const Color(0xFF059669);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.15 : 0.10),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  border: Border.all(
                    color: accentColor.withValues(alpha: isDark ? 0.28 : 0.22),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  Icons.developer_board_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.siliconState.getString(context),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocale.siliconStateSubtitle.getString(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: liveColor.withValues(alpha: isDark ? 0.12 : 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: liveColor.withValues(alpha: isDark ? 0.30 : 0.35),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: liveColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      AppLocale.liveBadge.getString(context),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: liveColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing14),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.20)),
          const SizedBox(height: AppConstants.spacing14),

          // ── Riel 1: Clústeres de CPU (Tacómetros LED) ─────────────────
          if (state.cpuClusters.isNotEmpty) ...[
            _buildCpuClusterSection(context),
            const SizedBox(height: AppConstants.spacing14),
          ],

          // ── Riel 2: Motor Gráfico & Bus DRAM (Tacómetros LED) ────────
          _buildGpuAndDramSection(context),
          const SizedBox(height: AppConstants.spacing14),

          // ── Riel 3: Núcleo Térmico & Smart Bypass ─────────────────────
          _buildThermalAndPowerSection(context),
        ],
      ),
    );
  }

  // ── 1. CPU Clusters Section ────────────────────────────────────────────────
  Widget _buildCpuClusterSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rawClusters = state.cpuClusters.split('|');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.memory_rounded,
              size: 13,
              color: cs.onSurfaceVariant.withValues(alpha: 0.80),
            ),
            const SizedBox(width: 5),
            Text(
              AppLocale.cpuClustersHeader.getString(context),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: cs.onSurfaceVariant.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing8),
        Row(
          children: [
            for (int i = 0; i < rawClusters.length; i++) ...[
              if (i > 0) const SizedBox(width: AppConstants.spacing8),
              Expanded(
                child: _buildClusterCard(
                  context,
                  index: i,
                  total: rawClusters.length,
                  raw: rawClusters[i],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildClusterCard(
    BuildContext context, {
    required int index,
    required int total,
    required String raw,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final color = _clusterAccentColor(index, total, isDark);
    final label = _clusterLabel(index, total);
    final freqText = _cleanClusterFreq(raw);
    final mhz = _parseFreqValue(raw);
    final ratio = _calcClusterRatio(index, total, mhz);
    final pct = (ratio * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 9),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.28 : 0.40),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: isDark ? 0.18 : 0.25),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            freqText,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          LedRevMeter(
            ratio: ratio,
            activeColor: color,
            totalSegments: 7,
          ),
        ],
      ),
    );
  }

  // ── 2. GPU & DRAM Section (Both with LED Rev Meters!) ──────────────────────
  Widget _buildGpuAndDramSection(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final gpuColor = isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706); // Warm Amber
    final dramColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB); // Dimensity Tech Blue

    final gpuRatio = _calcGpuRatio(state.gpuFreq);
    final dramRatio = _calcDramRatio(state.dramFreq);

    final gpuPct = (gpuRatio * 100).round();
    final dramPct = (dramRatio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.speed_rounded,
              size: 13,
              color: cs.onSurfaceVariant.withValues(alpha: 0.80),
            ),
            const SizedBox(width: 5),
            Text(
              AppLocale.gpuAndDramHeader.getString(context),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: cs.onSurfaceVariant.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing8),
        Row(
          children: [
            // ── GPU Core Module ──────────────────────────────────────────
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 9),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.28 : 0.40),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: isDark ? 0.18 : 0.25),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.speed_rounded,
                              size: 12,
                              color: gpuColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocale.gpuCore.getString(context),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$gpuPct%',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: gpuColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _cleanFreq(state.gpuFreq),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: gpuColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    LedRevMeter(
                      ratio: gpuRatio,
                      activeColor: gpuColor,
                      totalSegments: 7,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacing8),
            // ── DRAM Bus Module ──────────────────────────────────────────
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 9),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.28 : 0.40),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: isDark ? 0.18 : 0.25),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.developer_mode_rounded,
                              size: 12,
                              color: dramColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocale.busDram.getString(context),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$dramPct%',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: dramColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _cleanFreq(state.dramFreq),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: dramColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    LedRevMeter(
                      ratio: dramRatio,
                      activeColor: dramColor,
                      totalSegments: 7,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 3. Thermal & Power Section ─────────────────────────────────────────────
  Widget _buildThermalAndPowerSection(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final tempColor = state.socTempC != null
        ? _tempColor(state.socTempC!, isDark)
        : (isDark ? const Color(0xFF10B981) : const Color(0xFF059669));
    final thermalRatio = _calcThermalRatio(state.socTempC);
    final bypassColor = isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.thermostat_rounded,
              size: 13,
              color: cs.onSurfaceVariant.withValues(alpha: 0.80),
            ),
            const SizedBox(width: 5),
            Text(
              AppLocale.thermalAndPowerHeader.getString(context),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: cs.onSurfaceVariant.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing8),
        Row(
          children: [
            // ── SoC Thermal Core ─────────────────────────────────────────
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 9),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.28 : 0.40),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: isDark ? 0.18 : 0.25),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.thermostat_rounded,
                              size: 12,
                              color: tempColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocale.socSilicon.getString(context),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (state.socTempC != null)
                          _tempBadge(state.socTempC!, isDark),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      state.socTempC != null
                          ? '${state.socTempC!.toStringAsFixed(0)}°C'
                          : 'Normal',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: tempColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LedRevMeter(
                      ratio: thermalRatio,
                      activeColor: tempColor,
                      totalSegments: 7,
                      isThermal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacing8),
            // ── Power Rail & Bypass ──────────────────────────────────────
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 9),
                decoration: BoxDecoration(
                  color: state.chargeBypass
                      ? bypassColor.withValues(alpha: isDark ? 0.12 : 0.10)
                      : cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.28 : 0.40),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(
                    color: state.chargeBypass
                        ? bypassColor.withValues(alpha: isDark ? 0.40 : 0.35)
                        : cs.outlineVariant.withValues(alpha: isDark ? 0.18 : 0.25),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          state.chargeBypass
                              ? Icons.bolt_rounded
                              : Icons.battery_charging_full_rounded,
                          size: 12,
                          color: state.chargeBypass
                              ? bypassColor
                              : cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          state.chargeBypass
                              ? AppLocale.smartBypass.getString(context)
                              : AppLocale.powerRail.getString(context),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: state.chargeBypass
                                ? bypassColor
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      state.chargeBypass
                          ? AppLocale.directSilicon.getString(context)
                          : (state.batteryCapacityPct != null
                              ? AppLocale.batteryPct
                                  .getString(context)
                                  .replaceAll('{pct}', state.batteryCapacityPct.toString())
                              : AppLocale.batteryOk.getString(context)),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: state.chargeBypass
                            ? bypassColor
                            : cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      state.chargeBypass
                          ? AppLocale.cellIsolated.getString(context)
                          : (state.batteryTempC != null
                              ? AppLocale.batteryTempCell
                                  .getString(context)
                                  .replaceAll('{temp}', state.batteryTempC.toString())
                              : AppLocale.standardConsumption.getString(context)),
                      style: TextStyle(
                        fontSize: 9.5,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.75),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Helper Math & Formatters ───────────────────────────────────────────────
  Color _clusterAccentColor(int index, int total, bool isDark) {
    if (isDark) {
      if (total == 3) {
        if (index == 0) return const Color(0xFF38BDF8); // Sky blue 400 (Little)
        if (index == 1) return const Color(0xFF60A5FA); // Blue 400 (Mid)
        return const Color(0xFF818CF8); // Indigo 400 (Prime)
      }
      if (total == 2) {
        if (index == 0) return const Color(0xFF38BDF8);
        return const Color(0xFF818CF8);
      }
      return const Color(0xFF38BDF8);
    } else {
      if (total == 3) {
        if (index == 0) return const Color(0xFF0284C7); // Sky blue 600 (Little)
        if (index == 1) return const Color(0xFF2563EB); // Royal blue 600 (Mid)
        return const Color(0xFF4F46E5); // Indigo 600 (Prime)
      }
      if (total == 2) {
        if (index == 0) return const Color(0xFF0284C7);
        return const Color(0xFF4F46E5);
      }
      return const Color(0xFF2563EB);
    }
  }

  String _clusterLabel(int index, int total) {
    if (total == 3) {
      if (index == 0) return 'LITTLE (0-3)';
      if (index == 1) return 'MID (4-6)';
      return 'PRIME (7)';
    }
    if (total == 2) {
      if (index == 0) return 'LITTLE';
      return 'BIG';
    }
    return 'CLUSTER $index';
  }

  String _cleanClusterFreq(String raw) {
    final clean = raw.trim();
    final colonIdx = clean.indexOf(':');
    final val = colonIdx != -1 ? clean.substring(colonIdx + 1).trim() : clean;
    if (val.endsWith('MHz')) {
      final numStr = val.replaceAll('MHz', '').trim();
      final mhz = int.tryParse(numStr);
      if (mhz != null && mhz >= 1000) {
        final ghz = mhz / 1000.0;
        return '${ghz.toStringAsFixed(2)} GHz';
      }
    }
    return val;
  }

  int? _parseFreqValue(String raw) {
    final clean = raw.trim();
    final colonIdx = clean.indexOf(':');
    final val = colonIdx != -1 ? clean.substring(colonIdx + 1).trim() : clean;
    final numStr = val.replaceAll('MHz', '').replaceAll('GHz', '').trim();
    final parsed = double.tryParse(numStr);
    if (parsed == null) return null;
    if (val.contains('GHz') || parsed < 10) {
      return (parsed * 1000).round();
    }
    return parsed.round();
  }

  double _calcClusterRatio(int index, int total, int? mhz) {
    if (mhz == null) return 0.5;
    final (minMhz, maxMhz) = switch (index) {
      0 => (480, 2200),
      1 => (400, 2850),
      2 => (400, 3400),
      _ => (400, 3000),
    };
    if (maxMhz <= minMhz) return 0.5;
    final r = (mhz - minMhz) / (maxMhz - minMhz);
    return r.clamp(0.1, 1.0);
  }

  double _calcGpuRatio(String raw) {
    final mhz = _parseFreqValue(raw);
    if (mhz == null) return 0.20;
    // Dimensity 8300 Mali-G615 ranges ~200MHz - 1400MHz
    const minMhz = 200;
    const maxMhz = 1400;
    final r = (mhz - minMhz) / (maxMhz - minMhz);
    return r.clamp(0.12, 1.0);
  }

  double _calcDramRatio(String raw) {
    final mhz = _parseFreqValue(raw);
    if (mhz == null) return 0.25;
    // LPDDR5X ranges ~800MHz - 3200MHz
    const minMhz = 800;
    const maxMhz = 3200;
    final r = (mhz - minMhz) / (maxMhz - minMhz);
    return r.clamp(0.15, 1.0);
  }

  double _calcThermalRatio(double? temp) {
    if (temp == null) return 0.25;
    // Range 30C - 80C
    const minTemp = 30.0;
    const maxTemp = 80.0;
    final r = (temp - minTemp) / (maxTemp - minTemp);
    return r.clamp(0.14, 1.0);
  }

  Widget _tempBadge(double temp, bool isDark) {
    final (label, color) = switch (temp) {
      >= 70.0 => ('HOT', isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626)),
      >= 55.0 => ('WARM', isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706)),
      _ => ('OK', isDark ? const Color(0xFF10B981) : const Color(0xFF059669)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.30),
          width: 0.6,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  String _cleanFreq(String freq) {
    if (freq.isEmpty) return 'Auto';
    return freq.trim();
  }

  Color _tempColor(double temp, bool isDark) {
    if (temp >= 70.0) return isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
    if (temp >= 55.0) return isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706);
    return isDark ? const Color(0xFF10B981) : const Color(0xFF059669);
  }
}

/// Multi-segment LED Rev Meter.
class LedRevMeter extends StatelessWidget {
  final double ratio;
  final Color activeColor;
  final int totalSegments;
  final bool isThermal;

  const LedRevMeter({
    super.key,
    required this.ratio,
    required this.activeColor,
    this.totalSegments = 7,
    this.isThermal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final activeCount = (ratio * totalSegments).round().clamp(1, totalSegments);

    return Row(
      children: [
        for (int i = 0; i < totalSegments; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Expanded(
            child: Container(
              height: 4.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i < activeCount
                    ? (isThermal
                        ? _thermalSegmentColor(i, totalSegments, isDark)
                        : activeColor)
                    : (isDark
                        ? cs.surfaceContainerHighest.withValues(alpha: 0.35)
                        : const Color(0xFFE2E8F0)),
                boxShadow: i < activeCount
                    ? [
                        BoxShadow(
                          color: (isThermal
                                  ? _thermalSegmentColor(i, totalSegments, isDark)
                                  : activeColor)
                              .withValues(alpha: isDark ? 0.45 : 0.25),
                          blurRadius: isDark ? 3 : 1.5,
                          spreadRadius: isDark ? 0.2 : 0,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
  }

  static Color _thermalSegmentColor(int index, int total, bool isDark) {
    if (index >= 5) return isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
    if (index >= 3) return isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706);
    return isDark ? const Color(0xFF10B981) : const Color(0xFF059669);
  }
}
