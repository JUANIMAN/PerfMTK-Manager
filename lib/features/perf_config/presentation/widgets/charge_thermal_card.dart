import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/perf_config/presentation/widgets/section_card.dart';

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
  final bool hasHardwareBypass;

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
    this.hasHardwareBypass = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final gentleOptions = [0, 500, 1000, 1500];

    return SectionCard(
      title: hasHardwareBypass
          ? context.l10n.thermalChargeTitle
          : context.l10n.thermalFastChargeTitle,
      icon: Icons.bolt_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Charge Throttle / Hardware Bypass ──────────────────────────────
          if (hasChargeBypass) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasHardwareBypass
                            ? context.l10n.hwChargeBypassTitle
                            : context.l10n.smartFastChargeTitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      Text(
                        hasHardwareBypass
                            ? (bypassChargeThrottle
                                ? context.l10n.hwBypassActive
                                : context.l10n.hwBypassInactive)
                            : (bypassChargeThrottle
                                ? context.l10n.smartFastChargeActive
                                : context.l10n.smartFastChargeInactive),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              bypassChargeThrottle ? color : cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      Text(
                        hasHardwareBypass
                            ? context.l10n.hwChargeBypassDesc
                            : context.l10n.smartFastChargeDesc,
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.3,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: bypassChargeThrottle,
                  activeThumbColor: color,
                  onChanged: (v) {
                    HapticFeedback.lightImpact();
                    onChanged(
                      bypassChargeThrottle: v,
                      unlockFpsThermal: unlockFpsThermal,
                      batteryTempLimit: batteryTempLimit,
                      disableThermalServices: disableThermalServices,
                      gentleChargeMa: gentleChargeMa,
                      bypassMinBattPct: bypassMinBattPct,
                    );
                  },
                ),
              ],
            ),
            if (hasHardwareBypass && bypassChargeThrottle) ...[
              const SizedBox(height: AppConstants.spacing12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.bypassMinBatt,
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
                  onChanged: (v) {
                    final nv = v.round();
                    if (nv != bypassMinBattPct) {
                      HapticFeedback.selectionClick();
                    }
                    onChanged(
                      bypassChargeThrottle: bypassChargeThrottle,
                      unlockFpsThermal: unlockFpsThermal,
                      batteryTempLimit: batteryTempLimit,
                      disableThermalServices: disableThermalServices,
                      gentleChargeMa: gentleChargeMa,
                      bypassMinBattPct: nv,
                    );
                  },
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
                      context.l10n.unlockFpsThermal,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      unlockFpsThermal
                          ? context.l10n.unlockFpsActiveDesc
                          : context.l10n.unlockFpsInactiveDesc,
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
                onChanged: (v) {
                  HapticFeedback.lightImpact();
                  onChanged(
                    bypassChargeThrottle: bypassChargeThrottle,
                    unlockFpsThermal: v,
                    batteryTempLimit: batteryTempLimit,
                    disableThermalServices: disableThermalServices,
                    gentleChargeMa: gentleChargeMa,
                    bypassMinBattPct: bypassMinBattPct,
                  );
                },
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
                      context.l10n.disableThermalServices,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      context.l10n.disableThermalServicesDesc,
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
                onChanged: (v) {
                  HapticFeedback.lightImpact();
                  onChanged(
                    bypassChargeThrottle: bypassChargeThrottle,
                    unlockFpsThermal: unlockFpsThermal,
                    batteryTempLimit: batteryTempLimit,
                    disableThermalServices: v,
                    gentleChargeMa: gentleChargeMa,
                    bypassMinBattPct: bypassMinBattPct,
                  );
                },
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
                context.l10n.gentleCharge,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing4),
              Text(
                context.l10n.gentleChargeDesc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Row(
                children: gentleOptions.map((ma) {
                  final selected = gentleChargeMa == ma;
                  final label = ma == 0
                      ? context.l10n.gentleChargeDisabled
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
                          onTap: () {
                            if (gentleChargeMa != ma) {
                              HapticFeedback.selectionClick();
                            }
                            onChanged(
                              bypassChargeThrottle: bypassChargeThrottle,
                              unlockFpsThermal: unlockFpsThermal,
                              batteryTempLimit: batteryTempLimit,
                              disableThermalServices: disableThermalServices,
                              gentleChargeMa: ma,
                              bypassMinBattPct: bypassMinBattPct,
                            );
                          },
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
                context.l10n.batterySafetyGuard,
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