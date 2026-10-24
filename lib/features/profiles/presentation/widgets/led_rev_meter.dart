import 'package:flutter/material.dart';
import 'package:manager/core/design/design.dart';

/// Multi-segment LED Rev Meter.
class LedRevMeter extends StatelessWidget {
  final double ratio;
  final Color activeColor;
  final int totalSegments;
  final bool isThermal;

  const LedRevMeter({
    super.key,
    required this.ratio,
    required this.activeColor,
    this.totalSegments = 7,
    this.isThermal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final activeCount = (ratio * totalSegments).round().clamp(1, totalSegments);

    return Row(
      children: [
        for (int i = 0; i < totalSegments; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Expanded(
            child: Container(
              height: 4.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i < activeCount
                    ? (isThermal
                        ? context.perfColors.thermalSegment(i)
                        : activeColor)
                    : (isDark
                        ? cs.surfaceContainerHighest.withValues(alpha: 0.35)
                        : AppPalette.slate200),
                boxShadow: i < activeCount
                    ? [
                        BoxShadow(
                          color: (isThermal
                                  ? context.perfColors.thermalSegment(i)
                                  : activeColor)
                              .withValues(alpha: isDark ? 0.45 : 0.25),
                          blurRadius: isDark ? 3 : 1.5,
                          spreadRadius: isDark ? 0.2 : 0,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ],
    );
  }

}
