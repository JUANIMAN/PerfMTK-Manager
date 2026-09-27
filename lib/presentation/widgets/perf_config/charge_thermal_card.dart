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
  final bool disableThermalServices;
  final int gentleChargeMa;
  final int bypassMinBattPct;
  final Color color;
  final bool hasChargeBypass;

  final void Function({
    required bool bypassChargeThrottle,
    required bool unlockFpsThermal,
    required int batteryTempLimit,
    required bool disableThermalServices,
    required int gentleChargeMa,
    required int bypassMinBattPct,
  }) onChanged;

  const ChargeThermalCard({
    super.key,
    required this.bypassChargeThrottle,
    required this.unlockFpsThermal,
    required this.batteryTempLimit,
    this.disableThermalServices = false,
    this.gentleChargeMa = 0,
    this.bypassMinBattPct = 20,
    required this.color,
    this.hasChargeBypass = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final gentleOptions = [0, 500, 1000, 1500];

    return SectionCard(
      title: AppLocale.thermalChargeTitle.getString(context),
      icon: Icons.bolt_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Charge Bypass Throttle ────────────────────────────────────────
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
                            : AppLocale.bypassChargeInactiveDesc
                                .getString(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              bypassChargeThrottle ? color : cs.onSurfaceVariant,
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
                    disableThermalServices: disableThermalServices,
                    gentleChargeMa: gentleChargeMa,
                    bypassMinBattPct: bypassMinBattPct,
                  ),
                ),
              ],
            ),
            if (bypassChargeThrottle) ...[
              const SizedBox(height: AppConstants.spacing12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocale.bypassMinBatt.getString(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$bypassMinBattPct%',
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
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: bypassMinBattPct.toDouble().clamp(10, 50),
                  min: 10,
                  max: 50,
                  divisions: 8,
                  onChanged: (v) => onChanged(
                    bypassChargeThrottle: bypassChargeThrottle,
                    unlockFpsThermal: unlockFpsThermal,
                    batteryTempLimit: batteryTempLimit,
                    disableThermalServices: disableThermalServices,
                    gentleChargeMa: gentleChargeMa,
                    bypassMinBattPct: v.round(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppConstants.spacing16),
            Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: AppConstants.spacing8),
          ],

          // ── Unlock FPS Thermal ───────────────────────────────────────────
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
                  disableThermalServices: disableThermalServices,
                  gentleChargeMa: gentleChargeMa,
                  bypassMinBattPct: bypassMinBattPct,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppConstants.spacing8),

          // ── Disable OEM Thermal Services ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.disableThermalServices.getString(context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      AppLocale.disableThermalServicesDesc.getString(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: disableThermalServices
                            ? color
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: disableThermalServices,
                activeThumbColor: color,
                onChanged: (v) => onChanged(
                  bypassChargeThrottle: bypassChargeThrottle,
                  unlockFpsThermal: unlockFpsThermal,
                  batteryTempLimit: batteryTempLimit,
                  disableThermalServices: v,
                  gentleChargeMa: gentleChargeMa,
                  bypassMinBattPct: bypassMinBattPct,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppConstants.spacing8),

          // ── Gentle Charging Current ──────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocale.gentleCharge.getString(context),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing4),
              Text(
                AppLocale.gentleChargeDesc.getString(context),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Row(
                children: gentleOptions.map((ma) {
                  final selected = gentleChargeMa == ma;
                  final label = ma == 0
                      ? AppLocale.gentleChargeDisabled.getString(context)
                      : '${ma}mA';
                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: AppConstants.spacing6),
                      child: AnimatedContainer(
                        duration: AppConstants.animationFast,
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withValues(alpha: 0.15)
                              : cs.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMedium),
                          border: Border.all(
                            color: selected ? color : cs.outlineVariant,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => onChanged(
                            bypassChargeThrottle: bypassChargeThrottle,
                            unlockFpsThermal: unlockFpsThermal,
                            batteryTempLimit: batteryTempLimit,
                            disableThermalServices: disableThermalServices,
                            gentleChargeMa: ma,
                            bypassMinBattPct: bypassMinBattPct,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMedium),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.spacing8,
                              horizontal: AppConstants.spacing4,
                            ),
                            child: Text(
                              label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: selected ? color : cs.onSurfaceVariant,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppConstants.spacing8),

          // ── Battery Safety Guard ─────────────────────────────────────────
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
                disableThermalServices: disableThermalServices,
                gentleChargeMa: gentleChargeMa,
                bypassMinBattPct: bypassMinBattPct,
              ),
            ),
          ),
        ],
      ),
    );
  }
}