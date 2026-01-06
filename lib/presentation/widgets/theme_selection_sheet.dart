import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/custom_selection_tile.dart';

class ThemeSelectionSheet extends StatelessWidget {
  final ThemeMode currentMode;
  final Function(ThemeMode) onThemeSelected;

  const ThemeSelectionSheet({
    super.key,
    required this.currentMode,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final themes = [
      (
      mode: ThemeMode.system,
      icon: Icons.brightness_auto_rounded,
      title: AppLocale.themeSystem.getString(context),
      subtitle: AppLocale.themeSystemDesc.getString(context),
      ),
      (
      mode: ThemeMode.light,
      icon: Icons.light_mode_rounded,
      title: AppLocale.themeLight.getString(context),
      subtitle: AppLocale.themeLightDesc.getString(context),
      ),
      (
      mode: ThemeMode.dark,
      icon: Icons.dark_mode_rounded,
      title: AppLocale.themeDark.getString(context),
      subtitle: AppLocale.themeDarkDesc.getString(context),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXLarge),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppConstants.spacing12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppConstants.spacing20),
            Padding(
              padding: AppConstants.paddingHorizontal,
              child: Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Text(
                    AppLocale.selectTheme.getString(context),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing20),
            ...themes.map((theme) {
              final isSelected = currentMode == theme.mode;
              return SelectionTile(
                icon: theme.icon,
                title: theme.title,
                subtitle: theme.subtitle,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onThemeSelected(theme.mode);
                },
              );
            }),
            const SizedBox(height: AppConstants.spacing20),
          ],
        ),
      ),
    );
  }
}