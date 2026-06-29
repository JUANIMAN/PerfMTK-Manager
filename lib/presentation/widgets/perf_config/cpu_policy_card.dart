import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/data/models/device_config.dart';
import 'package:manager/presentation/widgets/perf_config/freq_slider.dart';
import 'package:manager/presentation/widgets/perf_config/governor_dropdown.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

/// Returns a distinct accent colour for each CPU cluster.
Color _clusterColor(int policyIndex) {
  const colors = [
    Color(0xFF5BA4FF), // Little — blue
    Color(0xFFFF6B35), // Mid — orange
    Color(0xFFB98EFF), // Prime — purple
  ];
  return colors[policyIndex.clamp(0, colors.length - 1)];
}

/// Returns the cluster icon for a given policy index.
IconData _clusterIcon(int policyIndex) {
  const icons = [
    Icons.memory_rounded,             // Little
    Icons.developer_board_rounded,    // Mid
    Icons.star_rounded,               // Prime
  ];
  return icons[policyIndex.clamp(0, icons.length - 1)];
}

/// One collapsible card for a CPU frequency policy cluster.
///
/// Exposes min/max frequency sliders, a governor dropdown, and an
/// online-cores stepper.  All changes are reported through [onChanged].
class CpuPolicyCard extends StatelessWidget {
  /// Hardware description for this cluster.
  final CpuPolicy policy;

  /// Index in the policies list (0 = Little, 1 = Mid, 2 = Prime).
  final int policyIndex;

  // ── Current values ────────────────────────────────────────────────────────
  final int currentMinFreq;
  final int currentMaxFreq;
  final String currentGovernor;
  final int onlineCores;
  final int totalCores;

  final void Function({
    required int minFreq,
    required int maxFreq,
    required String governor,
    required int onlineCores,
  }) onChanged;

  const CpuPolicyCard({
    super.key,
    required this.policy,
    required this.policyIndex,
    required this.currentMinFreq,
    required this.currentMaxFreq,
    required this.currentGovernor,
    required this.onlineCores,
    required this.totalCores,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = _clusterColor(policyIndex);
    final icon = _clusterIcon(policyIndex);

    return SectionCard(
      title: '${policy.clusterName} · ${policy.cpuLabel}',
      icon: icon,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Frequency sliders ────────────────────────────────────────────
          FreqSlider(
            label: 'Min Frequency',
            availableFreqs: policy.freqs,
            currentFreq: currentMinFreq,
            color: color,
            onChanged: (v) => _emit(minFreq: v),
          ),
          const SizedBox(height: AppConstants.spacing16),
          FreqSlider(
            label: 'Max Frequency',
            availableFreqs: policy.freqs,
            currentFreq: currentMaxFreq,
            color: color,
            onChanged: (v) => _emit(maxFreq: v),
          ),
          const SizedBox(height: AppConstants.spacing16),

          // ── Governor ─────────────────────────────────────────────────────
          if (policy.governors.isNotEmpty)
            GovernorDropdown(
              label: 'Governor',
              currentValue: currentGovernor,
              governors: policy.governors,
              color: color,
              onChanged: (v) => _emit(governor: v),
            ),

          const SizedBox(height: AppConstants.spacing16),

          // ── Online cores stepper ─────────────────────────────────────────
          _CoresStepper(
            label: 'Online Cores',
            totalCores: totalCores,
            currentOnline: onlineCores,
            color: color,
            onChanged: (v) => _emit(online: v),
          ),
        ],
      ),
    );
  }

  void _emit({
    int? minFreq,
    int? maxFreq,
    String? governor,
    int? online,
  }) {
    onChanged(
      minFreq: minFreq ?? currentMinFreq,
      maxFreq: maxFreq ?? currentMaxFreq,
      governor: governor ?? currentGovernor,
      onlineCores: online ?? onlineCores,
    );
  }
}

// ── Cores stepper ─────────────────────────────────────────────────────────────

class _CoresStepper extends StatelessWidget {
  final String label;
  final int totalCores;
  final int currentOnline;
  final Color color;
  final ValueChanged<int> onChanged;

  const _CoresStepper({
    required this.label,
    required this.totalCores,
    required this.currentOnline,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
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
              const SizedBox(height: AppConstants.spacing4),
              // Core dots
              Row(
                children: List.generate(totalCores, (i) {
                  final active = i < currentOnline;
                  return AnimatedContainer(
                    duration: AppConstants.animationFast,
                    margin:
                        const EdgeInsets.only(right: AppConstants.spacing6),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: active
                          ? color
                          : color.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppConstants.spacing4),
                      border: Border.all(
                        color: active
                            ? color
                            : color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: active ? Colors.white : color,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        // +/- buttons
        _StepButton(
          icon: Icons.remove_rounded,
          color: color,
          enabled: currentOnline > 0,
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged((currentOnline - 1).clamp(0, totalCores));
          },
        ),
        const SizedBox(width: AppConstants.spacing8),
        AnimatedSwitcher(
          duration: AppConstants.animationFast,
          child: Text(
            '$currentOnline/$totalCores',
            key: ValueKey(currentOnline),
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacing8),
        _StepButton(
          icon: Icons.add_rounded,
          color: color,
          enabled: currentOnline < totalCores,
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged((currentOnline + 1).clamp(0, totalCores));
          },
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _StepButton({
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: AppConstants.animationFast,
      opacity: enabled ? 1.0 : AppConstants.opacityDisabled,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(AppConstants.spacing8),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius:
              BorderRadius.circular(AppConstants.spacing8),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing6),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
}
