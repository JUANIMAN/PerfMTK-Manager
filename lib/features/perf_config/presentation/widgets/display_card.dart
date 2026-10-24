import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/perf_config/presentation/widgets/section_card.dart';

/// Display refresh rate configuration card.
class DisplayCard extends StatelessWidget {
  /// Target display refresh rate (0 = Auto/Dynamic, 60, 90, 120, 144).
  final int refreshRate;

  /// Max display FPS supported by panel (from hardware probe).
  final int maxDisplayFps;

  final Color color;
  final ValueChanged<int> onChanged;

  const DisplayCard({
    super.key,
    required this.refreshRate,
    this.maxDisplayFps = 0,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final maxFps = maxDisplayFps > 0 ? maxDisplayFps : 120;

    final options = <({int value, String label, IconData icon})>[
      (
        value: 0,
        label: context.l10n.refreshRateAuto,
        icon: Icons.auto_mode_rounded,
      ),
      (
        value: 60,
        label: context.l10n.refreshRate60,
        icon: Icons.speed_rounded,
      ),
      if (maxFps >= 90)
        (
          value: 90,
          label: context.l10n.refreshRate90,
          icon: Icons.speed_rounded,
        ),
      if (maxFps >= 120)
        (
          value: 120,
          label: context.l10n.refreshRate120,
          icon: Icons.speed_rounded,
        ),
      if (maxFps >= 144)
        (
          value: 144,
          label: context.l10n.refreshRate144,
          icon: Icons.speed_rounded,
        ),
    ];

    return SectionCard(
      title: context.l10n.displayTitle,
      icon: Icons.smartphone_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.displayRefreshDesc,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),
          Row(
            children: options.map((opt) {
              final selected = opt.value == refreshRate;
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
                      onTap: () {
                        if (opt.value != refreshRate) {
                          HapticFeedback.selectionClick();
                        }
                        onChanged(opt.value);
                      },
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
                              textAlign: TextAlign.center,
                            ),
                          ],
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
    );
  }
}
