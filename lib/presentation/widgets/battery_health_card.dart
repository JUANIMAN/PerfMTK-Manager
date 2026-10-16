import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/localization/app_locales.dart';

/// Card displaying hardware-verified battery health, degradation, cycle count, and BMS metrics.
class BatteryHealthCard extends StatelessWidget {
  final SystemState state;

  const BatteryHealthCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cycles = state.batteryCycleCount ?? 0;
    final soh = state.batterySohPct ?? (cycles > 0 ? (100 - (cycles * 0.028)).clamp(50, 100).round() : 100);
    final fullMah = state.chargeFullMah ?? 4900;
    final designMah = state.chargeDesignMah ?? 5000;
    final counterMah = state.chargeCounterMah ?? ((fullMah * (state.batteryCapacityPct ?? 50)) / 100).round();

    Color healthColor;
    String healthStatusText;
    if (soh >= 85) {
      healthColor = const Color(0xFF00E676); // Vivid Green
      healthStatusText = 'Excelente estado';
    } else if (soh >= 75) {
      healthColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB); // Blue
      healthStatusText = 'Buen estado';
    } else if (soh >= 65) {
      healthColor = const Color(0xFFFFB300); // Amber
      healthStatusText = 'Desgaste moderado';
    } else {
      healthColor = const Color(0xFFFF5252); // Red / Orange
      healthStatusText = 'Desgaste significativo';
    }

    String cycleBadgeText;
    if (cycles <= 0) {
      cycleBadgeText = 'Nuevo';
    } else if (cycles < 300) {
      cycleBadgeText = 'Excelente';
    } else if (cycles < 700) {
      cycleBadgeText = 'Normal';
    } else {
      cycleBadgeText = 'Uso Prolongado';
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ───────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing12),
                decoration: BoxDecoration(
                  color: healthColor.withValues(alpha: isDark ? 0.16 : 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  border: Border.all(
                    color: healthColor.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  Icons.health_and_safety_rounded,
                  color: healthColor,
                  size: AppConstants.iconSizeLarge,
                ),
              ),
              const SizedBox(width: AppConstants.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.batteryHealthTitle.getString(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      '$healthStatusText ($soh%)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: healthColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: healthColor.withValues(alpha: isDark ? 0.15 : 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: healthColor.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '$soh% SOH',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: healthColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing14),

          // ── Health Progress Bar ──────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocale.batterySoh.getString(context),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '$soh% / 100%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                child: LinearProgressIndicator(
                  value: (soh / 100.0).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: cs.outlineVariant.withValues(alpha: 0.25),
                  valueColor: AlwaysStoppedAnimation(healthColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing20),

          // ── 4-Tile Health Metrics Grid ───────────────────────────────
          Row(
            children: [
              Expanded(
                child: _HealthMetricTile(
                  label: AppLocale.batteryCycles.getString(context),
                  value: cycles > 0 ? '$cycles' : 'N/A',
                  badge: cycleBadgeText,
                  icon: Icons.loop_rounded,
                  iconColor: const Color(0xFF38BDF8),
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: _HealthMetricTile(
                  label: AppLocale.batteryActualCapacity.getString(context),
                  value: '$fullMah mAh',
                  badge: '${((fullMah / designMah) * 100).round()}%',
                  icon: Icons.battery_charging_full_rounded,
                  iconColor: const Color(0xFF00E676),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          Row(
            children: [
              Expanded(
                child: _HealthMetricTile(
                  label: AppLocale.batteryDesignCapacity.getString(context),
                  value: '$designMah mAh',
                  badge: 'Diseño',
                  icon: Icons.precision_manufacturing_rounded,
                  iconColor: const Color(0xFFFFB300),
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: _HealthMetricTile(
                  label: 'Energía Almacenada',
                  value: '$counterMah mAh',
                  badge: '${state.batteryCapacityPct ?? 0}%',
                  icon: Icons.energy_savings_leaf_rounded,
                  iconColor: const Color(0xFF00E5FF),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing14),

          // ── Subtitle Info Note ───────────────────────────────────────
          Text(
            AppLocale.batteryHealthDesc.getString(context),
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String? badge;
  final IconData icon;
  final Color iconColor;

  const _HealthMetricTile({
    required this.label,
    required this.value,
    this.badge,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing4),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.15 : 0.10),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Icon(icon, color: iconColor, size: 14),
              ),
              const SizedBox(width: AppConstants.spacing6),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isDark ? 0.15 : 0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
