import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/perf_config/presentation/widgets/freq_slider.dart';
import 'package:manager/features/perf_config/presentation/widgets/governor_dropdown.dart';
import 'package:manager/features/perf_config/presentation/widgets/section_card.dart';

/// GPU configuration card — frequency sliders (DVFS min/max or fixed toggle) + governor.
class GpuCard extends StatelessWidget {
  /// −1 internally means "re-enable DVFS" (written as -1 for gpufreqv2
  /// or 0 for legacy gpufreq by the repository). Any other value is a
  /// fixed frequency in **KHz**.
  final int gpuFreq;
  final String gpuGovernor;
  final int? gpuMinFreq;
  final int? gpuMaxFreq;

  /// Available GPU frequencies in KHz, sorted descending.
  final List<int> availableFreqs;
  final List<String> availableGovernors;

  /// False on legacy gpufreq devices where GPU_GOVERNOR="none".
  final bool hasGovernor;

  /// False on legacy gpufreq devices where min/max frequency tuneables are not supported.
  final bool supportsMinMaxFreq;

  final Color color;

  final void Function({
    int? freq,
    String? governor,
    int? minFreq,
    int? maxFreq,
  }) onChanged;

  const GpuCard({
    super.key,
    required this.gpuFreq,
    required this.gpuGovernor,
    this.gpuMinFreq,
    this.gpuMaxFreq,
    required this.availableFreqs,
    required this.availableGovernors,
    this.hasGovernor = true,
    this.supportsMinMaxFreq = true,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDvfs = gpuFreq == -1;

    final sortedFreqs = List<int>.from(availableFreqs)..sort();
    final lowestFreq = sortedFreqs.isNotEmpty ? sortedFreqs.first : 0;
    final highestFreq = sortedFreqs.isNotEmpty ? sortedFreqs.last : 0;

    final effectiveMin = (gpuMinFreq != null && gpuMinFreq! > 0)
        ? gpuMinFreq!
        : lowestFreq;
    final effectiveMax = (gpuMaxFreq != null && gpuMaxFreq! > 0)
        ? gpuMaxFreq!
        : highestFreq;

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
                      context.l10n.freqMode,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      isDvfs
                          ? context.l10n.dvfsAuto
                          : context.l10n.fixedFreq,
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
                  HapticFeedback.lightImpact();
                  if (fixed) {
                    // Default to highest freq when enabling fixed mode
                    final defaultFreq = highestFreq;
                    onChanged(
                      freq: defaultFreq,
                      governor: gpuGovernor,
                      minFreq: gpuMinFreq,
                      maxFreq: gpuMaxFreq,
                    );
                  } else {
                    onChanged(
                      freq: -1,
                      governor: gpuGovernor,
                      minFreq: gpuMinFreq,
                      maxFreq: gpuMaxFreq,
                    );
                  }
                },
              ),
            ],
          ),

          // ── Frequency controls (Fixed or DVFS Min/Max) ───────────────────
          AnimatedSize(
            duration: AppConstants.animationNormal,
            curve: Curves.easeOutCubic,
            child: !isDvfs && availableFreqs.isNotEmpty
                ? Column(
                    children: [
                      const SizedBox(height: AppConstants.spacing16),
                      FreqSlider(
                        label: context.l10n.fixedFreq,
                        availableFreqs: availableFreqs,
                        currentFreq: gpuFreq,
                        color: color,
                        isKHz: true,
                        onChanged: (v) => onChanged(
                          freq: v,
                          governor: gpuGovernor,
                          minFreq: gpuMinFreq,
                          maxFreq: gpuMaxFreq,
                        ),
                      ),
                    ],
                  )
                : (isDvfs && supportsMinMaxFreq && availableFreqs.isNotEmpty)
                    ? Column(
                        children: [
                          const SizedBox(height: AppConstants.spacing16),
                          FreqSlider(
                            label: context.l10n.minFreq,
                            availableFreqs: availableFreqs,
                            currentFreq: effectiveMin,
                            color: color,
                            isKHz: true,
                            onChanged: (v) {
                              final newMax =
                                  (effectiveMax < v) ? v : effectiveMax;
                              onChanged(
                                freq: -1,
                                governor: gpuGovernor,
                                minFreq: v,
                                maxFreq: newMax,
                              );
                            },
                          ),
                          const SizedBox(height: AppConstants.spacing16),
                          FreqSlider(
                            label: context.l10n.maxFreq,
                            availableFreqs: availableFreqs,
                            currentFreq: effectiveMax,
                            color: color,
                            isKHz: true,
                            onChanged: (v) {
                              final newMin =
                                  (effectiveMin > v) ? v : effectiveMin;
                              onChanged(
                                freq: -1,
                                governor: gpuGovernor,
                                minFreq: newMin,
                                maxFreq: v,
                              );
                            },
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
          ),

          if (availableGovernors.isNotEmpty && hasGovernor) ...[
            const SizedBox(height: AppConstants.spacing16),
            GovernorDropdown(
              label: context.l10n.governor,
              currentValue: gpuGovernor,
              governors: availableGovernors,
              color: color,
              onChanged: (v) => onChanged(
                freq: gpuFreq,
                governor: v,
                minFreq: gpuMinFreq,
                maxFreq: gpuMaxFreq,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
