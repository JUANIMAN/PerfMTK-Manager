import 'package:flutter/material.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/features/system/data/models/system_state.dart';
import 'package:manager/l10n/l10n.dart';

/// ── Hero Battery Card with Live Telemetry Grid ────────────────────────────
class LiveBatteryHeroCard extends StatelessWidget {
  final SystemState state;
  final bool hasHardwareBypass;

  const LiveBatteryHeroCard({
    super.key,
    required this.state,
    this.hasHardwareBypass = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final capacity = state.batteryCapacityPct ?? 50;
    final status = state.chargeStatus.toLowerCase();
    final isDischarging = status == 'discharging';
    final isCharging = status == 'charging';
    final isFull = status == 'full' || (capacity >= 100 && !isDischarging);
    final isConnectedToPower = !isDischarging && (isCharging || isFull || status == 'not charging');
    final isBypassActive = isConnectedToPower && state.chargeBypass;
    final isCareSuspended = isConnectedToPower && state.batteryCareSuspended;

    Color primaryColor;
    if (isBypassActive) {
      primaryColor = AppPalette.vividOrange; // Vivid orange
    } else if (isCareSuspended) {
      primaryColor = AppPalette.neonGreen; // Green (protected)
    } else if (isCharging) {
      primaryColor = AppPalette.neonGreen; // Charging green
    } else {
      primaryColor = context.perfColors.accent;
    }

    final temp = state.batteryTempC ?? 0;
    Color tempColor;
    if (temp >= 42) {
      tempColor = AppPalette.neonRed;
    } else if (temp >= 35) {
      tempColor = AppPalette.amberAccent;
    } else {
      tempColor = AppPalette.neonGreen;
    }

    final currentMa = state.chargeCurrentNowMa ?? 0;
    final voltageMv = state.chargeVoltageNowMv ?? 0;
    final powerW = state.chargePowerW ?? 0.0;

    String statusBadgeText;
    if (isBypassActive) {
      statusBadgeText = hasHardwareBypass ? 'Bypass Activo' : 'Carga Rápida';
    } else if (isCareSuspended) {
      statusBadgeText = 'Carga Protegida (${state.batteryCareLimitPct}%)';
    } else if (isCharging) {
      statusBadgeText = powerW >= 20.0 ? 'Turbo 67W' : 'Cargando';
    } else if (isFull) {
      statusBadgeText = 'Cargada (100%)';
    } else {
      statusBadgeText = 'Descargando';
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.spacing20),
      child: Column(
        children: [
          // ── Main Battery Level Row ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$capacity',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                      letterSpacing: -1.5,
                    ),
                  ),
                  Text(
                    '%',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing12,
                  vertical: AppConstants.spacing6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBypassActive
                          ? Icons.power_rounded
                          : (isCharging
                              ? Icons.bolt_rounded
                              : (isFull
                                  ? Icons.check_circle_rounded
                                  : Icons.battery_std_rounded)),
                      color: primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: AppConstants.spacing6),
                    Text(
                      statusBadgeText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing12),

          // ── Battery Progress Bar ───────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            child: LinearProgressIndicator(
              value: (capacity / 100.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: cs.outlineVariant.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation(primaryColor),
            ),
          ),

          const SizedBox(height: AppConstants.spacing20),

          // ── 4-Tile Live Metrics Grid ───────────────────────────────
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: isCharging ? 'Carga' : 'Consumo',
                  value: '${currentMa.abs()} mA',
                  icon: isCharging ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  iconColor: isCharging ? AppPalette.neonGreen : AppPalette.sky400,
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: _MetricTile(
                  label: context.l10n.currentVoltage,
                  value: '${(voltageMv / 1000.0).toStringAsFixed(2)} V',
                  icon: Icons.electric_bolt_rounded,
                  iconColor: AppPalette.neonAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: context.l10n.currentPower,
                  value: '${powerW.toStringAsFixed(2)} W',
                  icon: Icons.speed_rounded,
                  iconColor: AppPalette.neonCyan,
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: _MetricTile(
                  label: context.l10n.temperature,
                  value: '$temp °C',
                  icon: Icons.thermostat_rounded,
                  iconColor: tempColor,
                ),
              ),
            ],
          ),

          // ── 5. Dynamic Smart Estimation Banner ───────────────────────
          _buildEstimationBanner(
            context,
            state,
            primaryColor,
            isCharging,
            isBypassActive,
            isCareSuspended,
            hasHardwareBypass,
          ),
        ],
      ),
    );
  }

  Widget _buildEstimationBanner(
    BuildContext context,
    SystemState state,
    Color primaryColor,
    bool isCharging,
    bool isBypassActive,
    bool isCareSuspended,
    bool hasHardwareBypass,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (isBypassActive) {
      final bannerText = hasHardwareBypass
          ? 'Alimentación directa por cable (Bypass activo). La celda descansa.'
          : 'Carga rápida en juegos activa (límite térmico anulado).';
      return Container(
        margin: const EdgeInsets.only(top: AppConstants.spacing14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.30),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.bolt_rounded, size: 16, color: primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                bannerText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isCareSuspended) {
      return Container(
        margin: const EdgeInsets.only(top: AppConstants.spacing14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.30),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.shield_rounded, size: 16, color: primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Carga suspendida por protección de salud (${state.batteryCareLimitPct}% alcanzado).',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final capacity = state.batteryCapacityPct ?? 50;
    final fullMah = state.chargeFullMah ?? (state.chargeDesignMah ?? 5000);
    final counterMah = state.chargeCounterMah ?? ((fullMah * capacity) / 100).round();
    final absCurrentMa = (state.chargeCurrentNowMa ?? 0).abs();

    if (isCharging) {
      if (capacity >= 100) {
        return Container(
          margin: const EdgeInsets.only(top: AppConstants.spacing14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.30),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, size: 16, color: primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Batería completamente cargada (100%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (absCurrentMa > 150) {
        final remFullMah = (fullMah - counterMah).clamp(0, fullMah);
        final minToFull = ((remFullMah / absCurrentMa) * 60).round();

        int? minToCare;
        if (state.batteryCareEnabled && capacity < state.batteryCareLimitPct) {
          final careTargetMah = ((fullMah * state.batteryCareLimitPct) / 100).round();
          final remCareMah = (careTargetMah - counterMah).clamp(0, careTargetMah);
          minToCare = ((remCareMah / absCurrentMa) * 60).round();
        }

        String primaryText;
        String secondaryText;

        if (minToCare != null && minToCare > 0) {
          primaryText = minToCare >= 60
              ? '~${minToCare ~/ 60}h ${minToCare % 60}m hasta corte (${state.batteryCareLimitPct}%)'
              : '~$minToCare min hasta corte (${state.batteryCareLimitPct}%)';
          secondaryText = minToFull >= 60
              ? '~${minToFull ~/ 60}h ${minToFull % 60}m para 100%'
              : '~$minToFull min para 100%';
        } else {
          primaryText = minToFull >= 60
              ? '~${minToFull ~/ 60}h ${minToFull % 60}m para carga completa'
              : '~$minToFull min para carga completa';
          secondaryText = '$absCurrentMa mA';
        }

        return Container(
          margin: const EdgeInsets.only(top: AppConstants.spacing14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.30),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.timer_outlined, size: 16, color: primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      primaryText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      secondaryText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    } else {
      // Discharging
      if (absCurrentMa > 30 && counterMah > 0) {
        final totalMinutes = ((counterMah / absCurrentMa) * 60).round();
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;

        final String timeText;
        if (hours > 0) {
          timeText = '~$hours h $minutes m de autonomía restante';
        } else {
          timeText = '~$minutes m de autonomía restante';
        }

        return Container(
          margin: const EdgeInsets.only(top: AppConstants.spacing14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.30),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.hourglass_bottom_rounded, size: 16, color: primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'Consumo: $absCurrentMa mA',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          margin: const EdgeInsets.only(top: AppConstants.spacing14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.30),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.battery_saver_rounded, size: 16, color: primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Batería en reposo / Consumo mínimo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing12,
        vertical: AppConstants.spacing10,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.35 : 0.5),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.15 : 0.10),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: AppConstants.spacing10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
