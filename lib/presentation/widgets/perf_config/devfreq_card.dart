import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/perf_config/freq_slider.dart';
import 'package:manager/presentation/widgets/perf_config/governor_dropdown.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

/// DRAM DEVFREQ configuration card — governor selection + optional min frequency slider.
class DevfreqCard extends StatelessWidget {
  final String dvfGovernor;
  final int currentMinFreq;
  final List<int> availableFreqs;
  final List<String> availableGovernors;
  final Color color;
  final void Function({String? governor, int? minFreq}) onChanged;

  const DevfreqCard({
    super.key,
    required this.dvfGovernor,
    this.currentMinFreq = 0,
    this.availableFreqs = const [],
    required this.availableGovernors,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final govs = availableGovernors.isNotEmpty
        ? availableGovernors
        : const ['simple_ondemand', 'powersave', 'performance', 'userspace'];

    return SectionCard(
      title: 'DRAM DVFS',
      icon: Icons.storage_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (availableFreqs.isNotEmpty) ...[
            FreqSlider(
              label: AppLocale.minFreqDram.getString(context),
              availableFreqs: availableFreqs,
              currentFreq: currentMinFreq,
              color: color,
              isKHz: false,
              onChanged: (v) => onChanged(minFreq: v),
            ),
            const SizedBox(height: AppConstants.spacing16),
          ],
          GovernorDropdown(
            label: AppLocale.governor.getString(context),
            currentValue: dvfGovernor,
            governors: govs,
            color: color,
            onChanged: (v) => onChanged(governor: v),
          ),
        ],
      ),
    );
  }
}
