import 'package:flutter/material.dart';
import 'package:manager/config/app_constants.dart';

/// Formats a frequency value for display.
///
/// [isKHz] — true for CPU frequencies (stored in KHz),
///            false for GPU/DVF/UFS (stored in Hz).
String formatFreq(int value, {bool isKHz = true}) {
  if (isKHz) {
    // KHz → MHz / GHz
    final mhz = value / 1000.0;
    if (mhz >= 1000) {
      final ghz = mhz / 1000.0;
      // Show one decimal only when non-integer
      return '${ghz % 1 == 0 ? ghz.toInt() : ghz.toStringAsFixed(1)} GHz';
    }
    return '${mhz.toInt()} MHz';
  } else {
    // Hz → MHz / GHz
    final mhz = value / 1_000_000.0;
    if (mhz >= 1000) {
      final ghz = mhz / 1000.0;
      return '${ghz % 1 == 0 ? ghz.toInt() : ghz.toStringAsFixed(1)} GHz';
    }
    return '${mhz.toStringAsFixed(mhz % 1 == 0 ? 0 : 0)} MHz';
  }
}

/// A discrete frequency slider that snaps to values from [availableFreqs].
///
/// [availableFreqs] should be sorted **descending** (as stored in
/// device.conf).  The slider internally presents them in ascending order
/// so that dragging right = higher frequency.
class FreqSlider extends StatelessWidget {
  /// Label shown above the slider (e.g. "Min Frequency").
  final String label;

  /// Full list of valid frequencies (sorted descending), from device.conf.
  final List<int> availableFreqs;

  /// Currently selected frequency.
  final int currentFreq;

  /// Accent colour for the filled track and value label.
  final Color color;

  /// True if values are in KHz (CPU), false if in Hz (GPU/DVF/UFS).
  final bool isKHz;

  final ValueChanged<int> onChanged;

  const FreqSlider({
    super.key,
    required this.label,
    required this.availableFreqs,
    required this.currentFreq,
    required this.color,
    required this.onChanged,
    this.isKHz = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (availableFreqs.isEmpty) return const SizedBox.shrink();

    // Always sort ascending internally so left = min, right = max
    final ascending = List<int>.from(availableFreqs)..sort();
    final maxIdx = ascending.length - 1;

    // Find the closest index for currentFreq
    int currentIdx = ascending.indexOf(currentFreq);
    if (currentIdx < 0) {
      // Snap to nearest
      currentIdx = 0;
      int minDiff = (ascending[0] - currentFreq).abs();
      for (int i = 1; i < ascending.length; i++) {
        final diff = (ascending[i] - currentFreq).abs();
        if (diff < minDiff) {
          minDiff = diff;
          currentIdx = i;
        }
      }
    }

    final minLabel = formatFreq(ascending.first, isKHz: isKHz);
    final maxLabel = formatFreq(ascending.last, isKHz: isKHz);
    final currentLabel = formatFreq(ascending[currentIdx], isKHz: isKHz);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.16 : 0.10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.45 : 0.55),
                  width: 1.0,
                ),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.15),
                          blurRadius: 6,
                          spreadRadius: 0.5,
                        ),
                      ]
                    : null,
              ),
              child: AnimatedSwitcher(
                duration: AppConstants.animationFast,
                child: Text(
                  currentLabel,
                  key: ValueKey(currentLabel),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing4),

        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.16),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.20),
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.5),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: currentIdx.toDouble(),
            min: 0,
            max: maxIdx.toDouble(),
            divisions: maxIdx,
            onChanged: (v) {
              final idx = v.round().clamp(0, maxIdx);
              onChanged(ascending[idx]);
            },
          ),
        ),

        // Min / Max range labels
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                minLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                maxLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
