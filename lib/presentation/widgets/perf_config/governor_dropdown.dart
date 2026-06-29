import 'package:flutter/material.dart';
import 'package:manager/config/app_constants.dart';

/// Dropdown for selecting a kernel governor from a list.
class GovernorDropdown extends StatelessWidget {
  final String label;
  final String currentValue;
  final List<String> governors;
  final Color color;
  final ValueChanged<String> onChanged;

  const GovernorDropdown({
    super.key,
    required this.label,
    required this.currentValue,
    required this.governors,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Make sure currentValue is in the list; fall back to first item
    final safeValue =
        governors.contains(currentValue) ? currentValue : governors.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spacing6),
        DropdownButtonFormField<String>(
          initialValue: safeValue,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing12,
              vertical: AppConstants.spacing10,
            ),
            filled: true,
            fillColor: color.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: color, width: 1.5),
            ),
          ),
          dropdownColor: cs.surfaceContainerHighest,
          iconEnabledColor: color,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w500,
          ),
          items: governors
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
