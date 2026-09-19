import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';

/// Search input field for filtering installed applications.
class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: AppLocale.searchApps.getString(context),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant.withValues(alpha: 0.55),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 20,
          color: cs.primary.withValues(alpha: 0.70),
        ),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  size: 18,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.70),
                ),
                onPressed: () {
                  controller.clear();
                  onClear();
                  HapticFeedback.lightImpact();
                },
              )
            : null,
        filled: true,
        isDense: true,
        fillColor: isDark
            ? cs.surfaceContainerHigh.withValues(alpha: 0.50)
            : cs.surfaceContainer.withValues(alpha: 0.65),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.25),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.25),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: cs.primary.withValues(alpha: 0.70),
            width: 1.2,
          ),
        ),
      ),
      onChanged: onChanged,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
