import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

/// FPSGO configuration card — FORCE_ONOFF segmented control + BOOST_TA & rescue toggles.
class FpsgoCard extends StatelessWidget {
  /// 0 = off, 1 = on, 2 = free.
  final int forceOnOff;

  /// 0 = disabled, 1 = enabled.
  final int boostTa;

  /// 0 = disabled, 1 = enabled.
  final int rescueEnable;

  /// 0 = disabled, 1 = enabled.
  final int ultraRescue;

  /// 0 = standard, 1 = down-throttle suppressed.
  final int downThrottle;

  final Color color;

  final void Function({
    required int forceOnOff,
    required int boostTa,
    required int rescueEnable,
    required int ultraRescue,
    required int downThrottle,
  }) onChanged;

  const FpsgoCard({
    super.key,
    required this.forceOnOff,
    required this.boostTa,
    this.rescueEnable = 0,
    this.ultraRescue = 0,
    this.downThrottle = 0,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final taOn = boostTa == 1;
    final rescueOn = rescueEnable == 1;
    final ultraOn = ultraRescue == 1;
    final downThrottleOn = downThrottle == 1;

    return SectionCard(
      title: 'FPSGO',
      icon: Icons.speed_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── FORCE_ONOFF ──────────────────────────────────────────────────
          Text(
            AppLocale.forceOnOff.getString(context),
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          _SegmentedOption(
            options: [
              (
                value: 0,
                label: AppLocale.offOption.getString(context),
                icon: Icons.block_rounded,
              ),
              (
                value: 1,
                label: AppLocale.onOption.getString(context),
                icon: Icons.check_circle_rounded,
              ),
              (
                value: 2,
                label: AppLocale.freeOption.getString(context),
                icon: Icons.auto_mode_rounded,
              ),
            ],
            selectedValue: forceOnOff,
            color: color,
            onChanged: (v) => onChanged(
              forceOnOff: v,
              boostTa: boostTa,
              rescueEnable: rescueEnable,
              ultraRescue: ultraRescue,
              downThrottle: downThrottle,
            ),
          ),

          const SizedBox(height: AppConstants.spacing20),

          // ── BOOST_TA toggle ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.taBoost.getString(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      taOn
                          ? AppLocale.taBoostEnabled.getString(context)
                          : AppLocale.taBoostDisabled.getString(context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: taOn ? color : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: taOn,
                activeThumbColor: color,
                onChanged: (v) => onChanged(
                  forceOnOff: forceOnOff,
                  boostTa: v ? 1 : 0,
                  rescueEnable: rescueEnable,
                  ultraRescue: ultraRescue,
                  downThrottle: downThrottle,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing16),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppConstants.spacing8),

          // ── RESCUE_ENABLE toggle ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.rescueEnable.getString(context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      AppLocale.rescueEnableDesc.getString(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: rescueOn ? color : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: rescueOn,
                activeThumbColor: color,
                onChanged: (v) => onChanged(
                  forceOnOff: forceOnOff,
                  boostTa: boostTa,
                  rescueEnable: v ? 1 : 0,
                  ultraRescue: ultraRescue,
                  downThrottle: downThrottle,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing16),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppConstants.spacing8),

          // ── ULTRA_RESCUE toggle ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.ultraRescue.getString(context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      AppLocale.ultraRescueDesc.getString(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ultraOn ? color : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: ultraOn,
                activeThumbColor: color,
                onChanged: (v) => onChanged(
                  forceOnOff: forceOnOff,
                  boostTa: boostTa,
                  rescueEnable: rescueEnable,
                  ultraRescue: v ? 1 : 0,
                  downThrottle: downThrottle,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing16),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppConstants.spacing8),

          // ── DOWN_THROTTLE toggle ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.downThrottle.getString(context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      AppLocale.downThrottleDesc.getString(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: downThrottleOn ? color : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: downThrottleOn,
                activeThumbColor: color,
                onChanged: (v) => onChanged(
                  forceOnOff: forceOnOff,
                  boostTa: boostTa,
                  rescueEnable: rescueEnable,
                  ultraRescue: ultraRescue,
                  downThrottle: v ? 1 : 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Segmented option row ──────────────────────────────────────────────────────

class _SegmentedOption extends StatelessWidget {
  final List<({int value, String label, IconData icon})> options;
  final int selectedValue;
  final Color color;
  final ValueChanged<int> onChanged;

  const _SegmentedOption({
    required this.options,
    required this.selectedValue,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: options.map((opt) {
        final selected = opt.value == selectedValue;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: AppConstants.spacing6),
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
                onTap: () => onChanged(opt.value),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusMedium),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacing10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        opt.icon,
                        size: 18,
                        color: selected ? color : cs.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      Text(
                        opt.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: selected ? color : cs.onSurfaceVariant,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
