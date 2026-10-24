import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/perf_config/presentation/widgets/section_card.dart';

/// MediaTek Game Turbo (GBE) card — frame forecasting & thermal headroom
class GbeCard extends StatelessWidget {
  final int gbeEnable;
  final int gbeThrmHdrm;
  final Color color;
  final void Function(int enable, int thrmHdrm) onChanged;

  const GbeCard({
    super.key,
    required this.gbeEnable,
    required this.gbeThrmHdrm,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isEnabled = gbeEnable == 1;

    return SectionCard(
      title: context.l10n.gbeTitle,
      icon: Icons.sports_esports_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.gbeEnable,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      isEnabled
                          ? context.l10n.gbeActiveDesc
                          : context.l10n.gbeInactiveDesc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isEnabled ? color : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                activeThumbColor: color,
                onChanged: (v) {
                  HapticFeedback.lightImpact();
                  onChanged(v ? 1 : 0, gbeThrmHdrm);
                },
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: AppConstants.spacing16),
            Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: AppConstants.spacing8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.gbeThermalHeadroom,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$gbeThrmHdrm°C',
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
                value: gbeThrmHdrm.toDouble().clamp(0, 50),
                min: 0,
                max: 50,
                divisions: 50,
                onChanged: (v) => onChanged(gbeEnable, v.round()),
              ),
            ),
          ],
        ],
      ),
    );
  }
}