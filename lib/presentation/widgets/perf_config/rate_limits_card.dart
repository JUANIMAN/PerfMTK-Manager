import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/data/models/device_config.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';

/// Card for configuring scheduler CPU frequency transition rate limits.
class RateLimitsCard extends StatelessWidget {
  final List<int> downRateLimitUs;
  final List<int> upRateLimitUs;
  final List<CpuPolicy> policies;
  final Color color;
  final void Function(List<int> down, List<int> up) onChanged;

  const RateLimitsCard({
    super.key,
    required this.downRateLimitUs,
    required this.upRateLimitUs,
    required this.policies,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final count = policies.isNotEmpty
        ? policies.length
        : downRateLimitUs.length;

    // Ensure lists are at least `count` long (broadcast last value if needed).
    List<int> pad(List<int> src) {
      if (src.isEmpty) return List.filled(count, 1000);
      if (src.length >= count) return src.take(count).toList();
      return [...src, ...List.filled(count - src.length, src.last)];
    }

    final downs = pad(downRateLimitUs);
    final ups = pad(upRateLimitUs);

    return SectionCard(
      title: AppLocale.rateLimits.getString(context),
      icon: Icons.timer_outlined,
      color: color,
      initiallyExpanded: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i < policies.length)
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacing8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing8,
                        vertical: AppConstants.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(
                          AppConstants.spacing8,
                        ),
                        border: Border.all(
                          color: color.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Text(
                        policies[i].clusterName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Text(
                      policies[i].cpuLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: RateField(
                    label: AppLocale.downRateLimit.getString(context),
                    hint: '10000',
                    value: downs[i],
                    color: color,
                    onChanged: (v) {
                      final nd = List<int>.from(downs)..[i] = v;
                      onChanged(nd, ups);
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: RateField(
                    label: AppLocale.upRateLimit.getString(context),
                    hint: '1000',
                    value: ups[i],
                    color: color,
                    onChanged: (v) {
                      final nu = List<int>.from(ups)..[i] = v;
                      onChanged(downs, nu);
                    },
                  ),
                ),
              ],
            ),
            if (i < count - 1) const SizedBox(height: AppConstants.spacing16),
          ],
        ],
      ),
    );
  }
}

class RateField extends StatefulWidget {
  final String label;
  final String hint;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  const RateField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  State<RateField> createState() => _RateFieldState();
}

class _RateFieldState extends State<RateField> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toString());
    _focus = FocusNode();
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(RateField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_focus.hasFocus) {
      _ctrl.text = widget.value.toString();
    }
  }

  void _commit() {
    final v = int.tryParse(_ctrl.text);
    if (v != null && v != widget.value) widget.onChanged(v);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextField(
      controller: _ctrl,
      focusNode: _focus,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixText: 'µs',
        filled: true,
        fillColor: widget.color.withValues(alpha: 0.06),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing12,
          vertical: AppConstants.spacing10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: widget.color.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: widget.color.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: widget.color, width: 1.5),
        ),
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: cs.onSurfaceVariant,
        ),
      ),
      onSubmitted: (_) => _commit(),
    );
  }
}
