import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/data/models/device_config.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/perf_config/freq_slider.dart';
import 'package:manager/presentation/widgets/perf_config/governor_dropdown.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

/// Returns a distinct accent colour for each CPU cluster.
Color _clusterColor(int policyIndex, {bool isDark = true}) {
  const darkColors = [
    Color(0xFF38BDF8), // Little — sky blue
    Color(0xFF60A5FA), // Mid — royal blue
    Color(0xFF818CF8), // Prime — tech indigo
  ];
  const lightColors = [
    Color(0xFF0284C7), // Little — sky blue 600
    Color(0xFF2563EB), // Mid — royal blue 600
    Color(0xFF4F46E5), // Prime — indigo 600
  ];
  final colors = isDark ? darkColors : lightColors;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _clusterColor(policyIndex, isDark: isDark);
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
            label: AppLocale.minFreq.getString(context),
            availableFreqs: policy.freqs,
            currentFreq: currentMinFreq,
            color: color,
            onChanged: (v) => _emit(minFreq: v),
          ),
          const SizedBox(height: AppConstants.spacing16),
          FreqSlider(
            label: AppLocale.maxFreq.getString(context),
            availableFreqs: policy.freqs,
            currentFreq: currentMaxFreq,
            color: color,
            onChanged: (v) => _emit(maxFreq: v),
          ),
          const SizedBox(height: AppConstants.spacing16),

          // ── Governor ─────────────────────────────────────────────────────
          if (policy.governors.isNotEmpty)
            GovernorDropdown(
              label: AppLocale.governor.getString(context),
              currentValue: currentGovernor,
              governors: policy.governors,
              color: color,
              onChanged: (v) => _emit(governor: v),
            ),

          const SizedBox(height: AppConstants.spacing16),

          // ── Online cores stepper ─────────────────────────────────────────
          _CoresStepper(
            label: AppLocale.onlineCores.getString(context),
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
    final isDark = theme.brightness == Brightness.dark;

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
              // Core silicon cells
              Row(
                children: List.generate(totalCores, (i) {
                  final active = i < currentOnline;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (currentOnline == i + 1) {
                        onChanged(i);
                      } else {
                        onChanged(i + 1);
                      }
                    },
                    child: AnimatedContainer(
                      duration: AppConstants.animationFast,
                      margin: const EdgeInsets.only(right: 7),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: active
                            ? color.withValues(alpha: isDark ? 0.22 : 0.16)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : Colors.black.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: active
                              ? color.withValues(alpha: isDark ? 0.75 : 0.85)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.12)),
                          width: active ? 1.2 : 0.8,
                        ),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: isDark ? 0.30 : 0.15),
                                  blurRadius: 6,
                                  spreadRadius: 0.5,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: active
                                ? color
                                : (isDark
                                    ? cs.onSurfaceVariant.withValues(alpha: 0.40)
                                    : cs.onSurface.withValues(alpha: 0.45)),
                            fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 11,
                          ),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.40 : 0.50),
              width: 0.9,
            ),
          ),
          child: AnimatedSwitcher(
            duration: AppConstants.animationFast,
            child: Text(
              '$currentOnline/$totalCores',
              key: ValueKey(currentOnline),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedOpacity(
      duration: AppConstants.animationFast,
      opacity: enabled ? 1.0 : AppConstants.opacityDisabled,
      child: Material(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withValues(alpha: isDark ? 0.30 : 0.40),
                width: 0.8,
              ),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
        ),
      ),
    );
  }
}
