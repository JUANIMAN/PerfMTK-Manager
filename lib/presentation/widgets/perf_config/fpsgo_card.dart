import 'package:flutter/material.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

/// FPSGO configuration card — FORCE_ONOFF segmented control + BOOST_TA toggle.
class FpsgoCard extends StatelessWidget {
  /// 0 = off, 1 = on, 2 = free.
  final int forceOnOff;

  /// 0 = disabled, 1 = enabled.
  final int boostTa;
  final Color color;

  final void Function(int forceOnOff, int boostTa) onChanged;

  const FpsgoCard({
    super.key,
    required this.forceOnOff,
    required this.boostTa,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final taOn = boostTa == 1;

    return SectionCard(
      title: 'FPSGO',
      icon: Icons.speed_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── FORCE_ONOFF ──────────────────────────────────────────────────
          Text(
            'FORCE_ONOFF',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          _SegmentedOption(
            options: const [
              (value: 0, label: 'Off', icon: Icons.block_rounded),
              (value: 1, label: 'On', icon: Icons.check_circle_rounded),
              (value: 2, label: 'Free', icon: Icons.auto_mode_rounded),
            ],
            selectedValue: forceOnOff,
            color: color,
            onChanged: (v) => onChanged(v, boostTa),
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
                      'BOOST_TA',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      taOn ? 'TA boost enabled' : 'TA boost disabled',
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
                onChanged: (v) => onChanged(forceOnOff, v ? 1 : 0),
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
                  color: selected
                      ? color
                      : cs.outlineVariant,
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
