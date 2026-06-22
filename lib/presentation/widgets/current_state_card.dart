import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/config/app_constants.dart';

/// Generic current-state card used by screens that need to display
/// a current value (e.g. thermal state) without the gradient hero treatment.
/// The gradient hero variant is now inline in profiles_screen.dart.
class CurrentStateCard extends StatelessWidget {
  final String state;
  final IconData icon;
  final Color color;
  final String titleLocaleKey;
  final String stateLocaleKey;
  final String? descriptionLocaleKey;
  final bool isLoading;

  const CurrentStateCard({
    super.key,
    required this.state,
    required this.icon,
    required this.color,
    required this.titleLocaleKey,
    required this.stateLocaleKey,
    this.descriptionLocaleKey,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: AppConstants.paddingLarge,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: isLoading
                ? SizedBox(
                    width: AppConstants.iconSizeLarge,
                    height: AppConstants.iconSizeLarge,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  )
                : Icon(icon, color: color, size: AppConstants.iconSizeLarge),
          ),
          const SizedBox(width: AppConstants.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocale.getValue(titleLocaleKey).getString(context),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                AnimatedSwitcher(
                  duration: AppConstants.animationNormal,
                  child: Text(
                    isLoading
                        ? AppLocale.applying.getString(context)
                        : AppLocale.getValue(stateLocaleKey)
                            .getString(context),
                    key: ValueKey('$stateLocaleKey-$isLoading'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                if (descriptionLocaleKey != null) ...[
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    AppLocale.getValue(descriptionLocaleKey!)
                        .getString(context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}