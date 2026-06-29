import 'package:flutter/material.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/presentation/widgets/perf_config/governor_dropdown.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

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
              label: 'Governor',
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
                      'UFS_CLK_ENABLE',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      clkOn ? 'Clock enabled' : 'Clock disabled',
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
                onChanged: (v) =>
                    onChanged(ufsGovernor, v ? 1 : 0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
