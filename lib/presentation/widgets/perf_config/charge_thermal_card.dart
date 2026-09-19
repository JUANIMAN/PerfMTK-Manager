import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

/// Thermal & Charging bypass configuration card
class ChargeThermalCard extends StatelessWidget {
  final bool bypassChargeThrottle;
  final bool unlockFpsThermal;
  final int batteryTempLimit;
  final Color color;
  final bool hasChargeBypass;
  final void Function({
    required bool bypassChargeThrottle,
    required bool unlockFpsThermal,
    required int batteryTempLimit,
  }) onChanged;

  const ChargeThermalCard({
    super.key,
    required this.bypassChargeThrottle,
    required this.unlockFpsThermal,
    required this.batteryTempLimit,
    required this.color,
    this.hasChargeBypass = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SectionCard(
      title: AppLocale.thermalChargeTitle.getString(context),
      icon: Icons.bolt_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasChargeBypass) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocale.bypassChargeThrottle.getString(context),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      Text(
                        bypassChargeThrottle
                            ? AppLocale.bypassChargeActiveDesc.getString(context)
                            : AppLocale.bypassChargeInactiveDesc.getString(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: bypassChargeThrottle ? color : cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: bypassChargeThrottle,
                  activeThumbColor: color,
                  onChanged: (v) => onChanged(
                    bypassChargeThrottle: v,
                    unlockFpsThermal: unlockFpsThermal,
                    batteryTempLimit: batteryTempLimit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
            Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: AppConstants.spacing8),
          ],
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.unlockFpsThermal.getString(context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      unlockFpsThermal
                          ? AppLocale.unlockFpsActiveDesc.getString(context)
                          : AppLocale.unlockFpsInactiveDesc.getString(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: unlockFpsThermal ? color : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: unlockFpsThermal,
                activeThumbColor: color,
                onChanged: (v) => onChanged(
                  bypassChargeThrottle: bypassChargeThrottle,
                  unlockFpsThermal: v,
                  batteryTempLimit: batteryTempLimit,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppConstants.spacing8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocale.batterySafetyGuard.getString(context),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$batteryTempLimit°C',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: cs.outlineVariant,
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: batteryTempLimit.toDouble().clamp(40, 55),
              min: 40,
              max: 55,
              divisions: 15,
              onChanged: (v) => onChanged(
                bypassChargeThrottle: bypassChargeThrottle,
                unlockFpsThermal: unlockFpsThermal,
                batteryTempLimit: v.round(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}