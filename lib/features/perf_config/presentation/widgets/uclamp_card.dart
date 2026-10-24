import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/perf_config/presentation/widgets/section_card.dart';

/// EAS UCLAMP configuration card — Min / Max clamping for Top-App & Foreground
class UclampCard extends StatelessWidget {
  final int minTopApp;
  final int maxTopApp;
  final int minFg;
  final int maxFg;
  final Color color;
  final void Function({
    required int minTopApp,
    required int maxTopApp,
    required int minFg,
    required int maxFg,
  }) onChanged;

  const UclampCard({
    super.key,
    required this.minTopApp,
    required this.maxTopApp,
    required this.minFg,
    required this.maxFg,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SectionCard(
      title: context.l10n.uclamp,
      icon: Icons.compress_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSlider(
            context: context,
            label: context.l10n.uclampTopAppMin,
            value: minTopApp,
            min: 0,
            max: 100,
            onChanged: (v) => onChanged(
              minTopApp: v,
              maxTopApp: maxTopApp < v ? v : maxTopApp,
              minFg: minFg,
              maxFg: maxFg,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          _buildSlider(
            context: context,
            label: context.l10n.uclampTopAppMax,
            value: maxTopApp,
            min: 0,
            max: 100,
            onChanged: (v) => onChanged(
              minTopApp: minTopApp > v ? v : minTopApp,
              maxTopApp: v,
              minFg: minFg,
              maxFg: maxFg,
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppConstants.spacing8),
          _buildSlider(
            context: context,
            label: context.l10n.uclampFgMin,
            value: minFg,
            min: 0,
            max: 100,
            onChanged: (v) => onChanged(
              minTopApp: minTopApp,
              maxTopApp: maxTopApp,
              minFg: v,
              maxFg: maxFg < v ? v : maxFg,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          _buildSlider(
            context: context,
            label: context.l10n.uclampFgMax,
            value: maxFg,
            min: 0,
            max: 100,
            onChanged: (v) => onChanged(
              minTopApp: minTopApp,
              maxTopApp: maxTopApp,
              minFg: minFg > v ? v : minFg,
              maxFg: v,
            ),
          ),
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
              '$value%',
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
            value: value.toDouble().clamp(min.toDouble(), max.toDouble()),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (v) {
              final nv = v.round();
              if (nv != value && (nv % 5 == 0 || nv == min || nv == max)) {
                HapticFeedback.selectionClick();
              }
              onChanged(nv);
            },
          ),
        ),
      ],
    );
  }
}