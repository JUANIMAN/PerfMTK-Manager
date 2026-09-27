import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

/// Per-profile Thermal Guardian configuration card.
class ThermalGuardianConfigCard extends StatelessWidget {
  final bool enable;
  final int tempTarget;
  final int stepDownMax;
  final int uclampStepPct;
  final Color color;

  final void Function({
    bool? enable,
    int? tempTarget,
    int? stepDownMax,
    int? uclampStepPct,
  }) onChanged;

  const ThermalGuardianConfigCard({
    super.key,
    required this.enable,
    required this.tempTarget,
    required this.stepDownMax,
    required this.uclampStepPct,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SectionCard(
      title: AppLocale.tgProfileTitle.getString(context),
      icon: Icons.shield_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Enable Toggle ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.tgProfileTitle.getString(context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      AppLocale.tgProfileEnableDesc.getString(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: enable ? color : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enable,
                activeThumbColor: color,
                onChanged: (v) => onChanged(enable: v),
              ),
            ],
          ),

          if (enable) ...[
            const SizedBox(height: AppConstants.spacing16),
            Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: AppConstants.spacing8),

            // ── Target Temperature ──────────────────────────────────────
            _buildSlider(
              context: context,
              label: AppLocale.tgTargetTemp.getString(context),
              value: tempTarget,
              min: 40,
              max: 85,
              unit: '°C',
              onChanged: (v) => onChanged(tempTarget: v),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: AppConstants.spacing8),

            // ── Max Clamping Steps ──────────────────────────────────────
            _buildSlider(
              context: context,
              label: AppLocale.tgClampingAggressiveness.getString(context),
              value: stepDownMax,
              min: 1,
              max: 3,
              unit: '',
              onChanged: (v) => onChanged(stepDownMax: v),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: AppConstants.spacing8),

            // ── Uclamp Step Percentage ──────────────────────────────────
            _buildSlider(
              context: context,
              label: AppLocale.tgUclampStep.getString(context),
              value: uclampStepPct,
              min: 5,
              max: 25,
              unit: '%',
              onChanged: (v) => onChanged(uclampStepPct: v),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSlider({
    required BuildContext context,
    required String label,
    required int value,
    required int min,
    required int max,
    required String unit,
    required ValueChanged<int> onChanged,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value$unit',
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
            overlayColor: color.withValues(alpha: 0.15),
            trackHeight: 3.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
          ),
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min > 0 ? max - min : null,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}
