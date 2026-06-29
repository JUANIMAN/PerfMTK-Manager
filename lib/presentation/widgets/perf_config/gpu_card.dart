import 'package:flutter/material.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/presentation/widgets/perf_config/freq_slider.dart';
import 'package:manager/presentation/widgets/perf_config/governor_dropdown.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

/// GPU configuration card — frequency slider (or DVFS toggle) + governor.
class GpuCard extends StatelessWidget {
  /// −1 internally means "re-enable DVFS" (written as -1 for gpufreqv2
  /// or 0 for legacy gpufreq by the repository). Any other value is a
  /// fixed frequency in **KHz**.
  final int gpuFreq;
  final String gpuGovernor;

  /// Available GPU frequencies in KHz, sorted descending.
  final List<int> availableFreqs;
  final List<String> availableGovernors;

  /// False on legacy gpufreq devices where GPU_GOVERNOR="none".
  final bool hasGovernor;
  final Color color;

  final void Function(int gpuFreq, String gpuGovernor) onChanged;

  const GpuCard({
    super.key,
    required this.gpuFreq,
    required this.gpuGovernor,
    required this.availableFreqs,
    required this.availableGovernors,
    this.hasGovernor = true,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDvfs = gpuFreq == -1;

    return SectionCard(
      title: 'GPU',
      icon: Icons.memory_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── DVFS / Fixed toggle ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequency Mode',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      isDvfs ? 'DVFS — Auto' : 'Fixed Frequency',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: !isDvfs,
                activeThumbColor: color,
                onChanged: (fixed) {
                  if (fixed) {
                    // Default to highest freq when enabling fixed mode
                    final defaultFreq = availableFreqs.isNotEmpty
                        ? availableFreqs.first
                        : 0;
                    onChanged(defaultFreq, gpuGovernor);
                  } else {
                    onChanged(-1, gpuGovernor);
                  }
                },
              ),
            ],
          ),

          // ── Frequency slider (only when in fixed mode) ───────────────────
          AnimatedSize(
            duration: AppConstants.animationNormal,
            curve: Curves.easeOutCubic,
            child: !isDvfs && availableFreqs.isNotEmpty
                ? Column(
                    children: [
                      const SizedBox(height: AppConstants.spacing16),
                      FreqSlider(
                        label: 'Fixed Frequency',
                        availableFreqs: availableFreqs,
                        currentFreq: gpuFreq,
                        color: color,
                        isKHz: true,
                        onChanged: (v) => onChanged(v, gpuGovernor),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          if (availableGovernors.isNotEmpty && hasGovernor) ...[
            const SizedBox(height: AppConstants.spacing16),
            GovernorDropdown(
              label: 'Governor',
              currentValue: gpuGovernor,
              governors: availableGovernors,
              color: color,
              onChanged: (v) => onChanged(gpuFreq, v),
            ),
          ],
        ],
      ),
    );
  }
}
