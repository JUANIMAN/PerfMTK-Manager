import 'package:flutter/material.dart';
import 'package:manager/presentation/widgets/perf_config/governor_dropdown.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

/// DRAM DEVFREQ configuration card — governor selection only.
class DevfreqCard extends StatelessWidget {
  final String dvfGovernor;
  final List<String> availableGovernors;
  final Color color;
  final ValueChanged<String> onChanged;

  const DevfreqCard({
    super.key,
    required this.dvfGovernor,
    required this.availableGovernors,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'DRAM DVFS',
      icon: Icons.storage_rounded,
      color: color,
      child: availableGovernors.isNotEmpty
          ? GovernorDropdown(
              label: 'Governor',
              currentValue: dvfGovernor,
              governors: availableGovernors,
              color: color,
              onChanged: onChanged,
            )
          : const SizedBox.shrink(),
    );
  }
}
