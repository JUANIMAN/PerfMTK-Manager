import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

/// Virtual Memory (VM), ZRAM, and MGLRU configuration card.
class VmCard extends StatelessWidget {
  final int swappiness;
  final bool mglru;
  final int watermarkScaleFactor;
  final int compactionProactiveness;
  final bool compactOnLaunch;
  final int statInterval;
  final Color color;

  final void Function({
    int? swappiness,
    bool? mglru,
    int? watermarkScaleFactor,
    int? compactionProactiveness,
    bool? compactOnLaunch,
    int? statInterval,
  }) onChanged;

  const VmCard({
    super.key,
    required this.swappiness,
    required this.mglru,
    required this.watermarkScaleFactor,
    required this.compactionProactiveness,
    required this.compactOnLaunch,
    required this.statInterval,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SectionCard(
      title: AppLocale.vmTitle.getString(context),
      icon: Icons.memory_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Swappiness ──────────────────────────────────────────────────
          _buildSlider(
            context: context,
            label: AppLocale.swappiness.getString(context),
            desc: AppLocale.swappinessDesc.getString(context),
            value: swappiness,
            min: 0,
            max: 200,
            unit: '',
            onChanged: (v) => onChanged(swappiness: v),
          ),
          const SizedBox(height: AppConstants.spacing16),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppConstants.spacing8),

          // ── MGLRU ───────────────────────────────────────────────────────
          _buildSwitch(
            context: context,
            title: AppLocale.mglru.getString(context),
            desc: AppLocale.mglruDesc.getString(context),
            value: mglru,
            onChanged: (v) => onChanged(mglru: v),
          ),
          const SizedBox(height: AppConstants.spacing16),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppConstants.spacing8),

          // ── Watermark Scale Factor ──────────────────────────────────────
          _buildSlider(
            context: context,
            label: AppLocale.watermarkScale.getString(context),
            desc: AppLocale.watermarkScaleDesc.getString(context),
            value: watermarkScaleFactor,
            min: 50,
            max: 300,
            unit: '',
            onChanged: (v) => onChanged(watermarkScaleFactor: v),
          ),
          const SizedBox(height: AppConstants.spacing16),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppConstants.spacing8),

          // ── Compaction Proactiveness ────────────────────────────────────
          _buildSlider(
            context: context,
            label: AppLocale.compactionProactiveness.getString(context),
            desc: AppLocale.compactionProactivenessDesc.getString(context),
            value: compactionProactiveness,
            min: 0,
            max: 100,
            unit: '%',
            onChanged: (v) => onChanged(compactionProactiveness: v),
          ),
          const SizedBox(height: AppConstants.spacing16),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppConstants.spacing8),

          // ── Compact On Launch ───────────────────────────────────────────
          _buildSwitch(
            context: context,
            title: AppLocale.compactOnLaunch.getString(context),
            desc: AppLocale.compactOnLaunchDesc.getString(context),
            value: compactOnLaunch,
            onChanged: (v) => onChanged(compactOnLaunch: v),
          ),
          const SizedBox(height: AppConstants.spacing16),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppConstants.spacing8),

          // ── Stat Interval ───────────────────────────────────────────────
          _buildSlider(
            context: context,
            label: AppLocale.statInterval.getString(context),
            value: statInterval,
            min: 1,
            max: 60,
            unit: 's',
            onChanged: (v) => onChanged(statInterval: v),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required BuildContext context,
    required String title,
    required String desc,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.spacing4),
              Text(
                desc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: value ? color : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSlider({
    required BuildContext context,
    required String label,
    String? desc,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (desc != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacing8),
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
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}
