import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/perf_config/presentation/widgets/governor_dropdown.dart';
import 'package:manager/features/perf_config/presentation/widgets/section_card.dart';

/// UFS storage configuration card — governor + clock enable toggle.
class UfsCard extends StatelessWidget {
  final String ufsGovernor;

  /// 0 = clock disabled, 1 = clock enabled.
  final int ufsClkEnable;
  final List<String> availableGovernors;
  final Color color;

  final void Function(String governor, int clkEnable) onChanged;

  const UfsCard({
    super.key,
    required this.ufsGovernor,
    required this.ufsClkEnable,
    required this.availableGovernors,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final clkOn = ufsClkEnable == 1;

    return SectionCard(
      title: 'UFS Storage',
      icon: Icons.sim_card_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (availableGovernors.isNotEmpty)
            GovernorDropdown(
              label: context.l10n.governor,
              currentValue: ufsGovernor,
              governors: availableGovernors,
              color: color,
              onChanged: (v) => onChanged(v, ufsClkEnable),
            ),
          const SizedBox(height: AppConstants.spacing16),

          // ── Clock enable toggle ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.ufsClkEnable,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      clkOn
                          ? context.l10n.clockEnabled
                          : context.l10n.clockDisabled,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: clkOn
                            ? color
                            : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: clkOn,
                activeThumbColor: color,
                onChanged: (v) {
                  HapticFeedback.lightImpact();
                  onChanged(ufsGovernor, v ? 1 : 0);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
