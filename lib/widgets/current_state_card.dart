import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';

class CurrentStateCard extends StatelessWidget {
  final String state;
  final IconData icon;
  final Color color;
  final String titleLocaleKey;
  final String stateLocaleKey;
  final String? descriptionLocaleKey;

  const CurrentStateCard({
    super.key,
    required this.state,
    required this.icon,
    required this.color,
    required this.titleLocaleKey,
    required this.stateLocaleKey,
    this.descriptionLocaleKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocale.getValue(titleLocaleKey).getString(context),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildStateContent(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        _buildIconContainer(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocale.getValue(stateLocaleKey).getString(context),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (descriptionLocaleKey != null) ...[
                const SizedBox(height: 4),
                _buildDescription(context, theme),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconContainer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }

  Widget _buildDescription(BuildContext context, ThemeData theme) {
    return Text(
      AppLocale.getValue(descriptionLocaleKey!).getString(context),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
