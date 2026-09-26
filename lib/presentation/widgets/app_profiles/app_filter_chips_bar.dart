import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/providers/app_profile_provider.dart';

/// Horizontal bar showing App filter chips (All, Configured, Not Configured) and system apps toggle.
class AppFilterChipsBar extends StatelessWidget {
  final AppFilterType selectedFilter;
  final bool includeSystemApps;
  final bool isLoading;
  final int? totalCount;
  final int? configuredCount;
  final int? notConfiguredCount;
  final ValueChanged<AppFilterType> onFilterSelected;
  final ValueChanged<bool> onToggleSystemApps;

  const AppFilterChipsBar({
    super.key,
    required this.selectedFilter,
    required this.includeSystemApps,
    required this.isLoading,
    required this.onFilterSelected,
    required this.onToggleSystemApps,
    this.totalCount,
    this.configuredCount,
    this.notConfiguredCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing4,
        AppConstants.spacing16,
        AppConstants.spacing8,
      ),
      child: Row(
        children: [
          // Filter chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip(
                    context,
                    AppFilterType.all,
                    AppLocale.allApps.getString(context),
                    Icons.apps_rounded,
                    totalCount,
                  ),
                  const SizedBox(width: AppConstants.spacing6),
                  _buildFilterChip(
                    context,
                    AppFilterType.configured,
                    AppLocale.configuredApps.getString(context),
                    Icons.check_circle_outline_rounded,
                    configuredCount,
                  ),
                  const SizedBox(width: AppConstants.spacing6),
                  _buildFilterChip(
                    context,
                    AppFilterType.notConfigured,
                    AppLocale.notConfiguredApps.getString(context),
                    Icons.pending_outlined,
                    notConfiguredCount,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: AppConstants.spacing8),

          // System apps toggle — modern glowing icon button
          Tooltip(
            message: AppLocale.includeSystemApps.getString(context),
            child: AnimatedContainer(
              duration: AppConstants.animationFast,
              decoration: BoxDecoration(
                color: includeSystemApps
                    ? theme.colorScheme.primary.withValues(alpha: 0.16)
                    : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: includeSystemApps
                      ? theme.colorScheme.primary.withValues(alpha: 0.50)
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                  width: 1.0,
                ),
                boxShadow: includeSystemApps
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.22),
                          blurRadius: 8,
                          spreadRadius: 0.5,
                        ),
                      ]
                    : null,
              ),
              child: IgnorePointer(
                ignoring: isLoading,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onToggleSystemApps(!includeSystemApps);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacing6),
                    child: Icon(
                      Icons.security_rounded,
                      size: 17,
                      color: includeSystemApps
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.70),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    AppFilterType filterType,
    String label,
    IconData icon,
    int? count,
  ) {
    final isSelected = selectedFilter == filterType;
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        onFilterSelected(filterType);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 5.5,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.16)
              : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.50)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.20),
                    blurRadius: 8,
                    spreadRadius: 0.5,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? color
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.70),
            ),
            const SizedBox(width: AppConstants.spacing6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? color
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.25)
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.60),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? color
                        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.80),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
