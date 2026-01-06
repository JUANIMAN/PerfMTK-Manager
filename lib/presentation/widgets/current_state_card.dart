import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/config/app_constants.dart';

class CurrentStateCard extends StatefulWidget {
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
  State<CurrentStateCard> createState() => _CurrentStateCardState();
}

class _CurrentStateCardState extends State<CurrentStateCard>
    with SingleTickerProviderStateMixin, EntryAnimationMixin {

  @override
  void initState() {
    super.initState();
    initEntryAnimation();
  }

  @override
  void dispose() {
    disposeEntryAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return buildWithEntryAnimation(
      Card(
        elevation: AppConstants.elevationMedium,
        shadowColor: widget.color.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
          side: BorderSide(
            color: widget.color.light,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                color: widget.color.light,
              ),
              child: Padding(
                padding: AppConstants.paddingLarge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: AppConstants.iconSizeMedium,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppConstants.spacing8),
                        Text(
                          AppLocale.getValue(widget.titleLocaleKey).getString(context),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacing20),
                    Row(
                      children: [
                        IconContainer(
                          icon: widget.icon,
                          color: widget.color,
                          size: AppConstants.spacing16,
                          iconSize: AppConstants.iconSizeXLarge,
                        ),
                        const SizedBox(width: AppConstants.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocale.getValue(widget.stateLocaleKey).getString(context),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: widget.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.descriptionLocaleKey != null) ...[
                                const SizedBox(height: AppConstants.spacing6),
                                Text(
                                  AppLocale.getValue(widget.descriptionLocaleKey!).getString(context),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
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
                  ],
                ),
              ),
            ),
            if (widget.isLoading) _buildLoadingOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned.fill(
      child: AnimatedOpacity(
        duration: AppConstants.animationFast,
        opacity: widget.isLoading ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            color: colorScheme.surface.subtle,
          ),
          child: Center(
            child: Container(
              padding: AppConstants.paddingNormal,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.light,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: AppConstants.iconSizeNormal,
                    height: AppConstants.iconSizeNormal,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing16),
                  Text(
                    AppLocale.applying.getString(context),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}