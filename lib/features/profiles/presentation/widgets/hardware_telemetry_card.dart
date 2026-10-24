import 'package:flutter/material.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/features/system/data/models/system_state.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/profiles/presentation/widgets/led_rev_meter.dart';

/// Cyber-Engine Unified Hardware Telemetry HUD with multi-segment LED rev meters.
class HardwareTelemetryCard extends StatelessWidget {
  final SystemState state;
  final bool hasHardwareBypass;

  const HardwareTelemetryCard({
    super.key,
    required this.state,
    this.hasHardwareBypass = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = context.perfColors.accent;
    final liveColor = context.perfColors.live;

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
                      context.l10n.siliconState,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.siliconStateSubtitle,
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
                      context.l10n.liveBadge,
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
              context.l10n.cpuClustersHeader,
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

    final color = context.perfColors.clusterAccent(index, total);
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

    final gpuColor = context.perfColors.warm; // Warm Amber
    final dramColor = context.perfColors.accent; // Dimensity Tech Blue

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
              context.l10n.gpuAndDramHeader,
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
                              context.l10n.gpuCore,
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
                              context.l10n.busDram,
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
        ? context.perfColors.tempColor(state.socTempC!)
        : (context.perfColors.live);
    final thermalRatio = _calcThermalRatio(state.socTempC);
    final bypassColor = context.perfColors.warm;

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
              context.l10n.thermalAndPowerHeader,
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
                              context.l10n.socSilicon,
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
                          _tempBadge(state.socTempC!, isDark, context.perfColors),
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
                              ? (hasHardwareBypass
                                  ? context.l10n.smartBypass
                                  : context.l10n.smartFastChargeTitle
                                      .toUpperCase())
                              : context.l10n.powerRail,
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
                          ? (hasHardwareBypass
                              ? context.l10n.directSilicon
                              : context.l10n.smartFastChargeTelemetry)
                          : (state.batteryCapacityPct != null
                              ? context.l10n.batteryPct(state.batteryCapacityPct.toString())
                              : context.l10n.batteryOk),
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
                          ? (hasHardwareBypass
                              ? context.l10n.cellIsolated
                              : context.l10n.smartFastChargeTelemetryDesc)
                          : (state.batteryTempC != null
                              ? context.l10n.batteryTempCell(state.batteryTempC.toString())
                              : context.l10n.standardConsumption),
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

    // Detect if telemetry reports effective data rate (e.g. 8533 MT/s)
    // or raw bus clock (e.g. LPDDR4X ~2133MHz, LPDDR5 ~3200MHz, LPDDR5X ~4266MHz)
    final double minMhz;
    final double maxMhz;

    if (mhz > 4500) {
      // Effective DDR rate (LPDDR5: 6400, LPDDR5X: 8533/9600)
      minMhz = 800;
      maxMhz = 8533;
    } else if (mhz > 3200) {
      // LPDDR5X bus clock (~4266MHz max)
      minMhz = 600;
      maxMhz = 4266;
    } else if (mhz > 2133) {
      // LPDDR5 bus clock (~3200MHz max)
      minMhz = 400;
      maxMhz = 3200;
    } else {
      // LPDDR4X / legacy bus clock (~2133MHz max) or lower power steps
      minMhz = 300;
      maxMhz = 2133;
    }

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

  Widget _tempBadge(double temp, bool isDark, PerfColors colors) {
    final color = colors.tempColor(temp);
    final label = temp >= 70.0 ? 'HOT' : (temp >= 55.0 ? 'WARM' : 'OK');

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

}
