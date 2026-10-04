import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/perf_config/freq_slider.dart';
import 'package:manager/presentation/widgets/perf_config/governor_dropdown.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

/// DRAM DEVFREQ configuration card — governor selection + min/max frequency sliders.
class DevfreqCard extends StatelessWidget {
  final String dvfGovernor;
  final int currentMinFreq;
  final int currentMaxFreq;
  final List<int> availableFreqs;
  final List<String> availableGovernors;
  final Color color;
  final void Function({String? governor, int? minFreq, int? maxFreq}) onChanged;

  const DevfreqCard({
    super.key,
    required this.dvfGovernor,
    this.currentMinFreq = 0,
    this.currentMaxFreq = 0,
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

    final sortedFreqs = List<int>.from(availableFreqs)..sort();
    final lowestFreq = sortedFreqs.isNotEmpty ? sortedFreqs.first : 0;
    final highestFreq = sortedFreqs.isNotEmpty ? sortedFreqs.last : 0;

    final effectiveMin = (currentMinFreq > 0) ? currentMinFreq : lowestFreq;
    final effectiveMax = (currentMaxFreq > 0) ? currentMaxFreq : highestFreq;

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
              currentFreq: effectiveMin,
              color: color,
              isKHz: false,
              onChanged: (v) => onChanged(
                minFreq: v,
                maxFreq: effectiveMax < v ? v : effectiveMax,
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            FreqSlider(
              label: AppLocale.maxFreqDram.getString(context),
              availableFreqs: availableFreqs,
              currentFreq: effectiveMax,
              color: color,
              isKHz: false,
              onChanged: (v) {
                onChanged(
                  minFreq: effectiveMin > v ? v : effectiveMin,
                  maxFreq: v,
                );
              },
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
