import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/settings/presentation/widgets/custom_selection_tile.dart';

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
      title: context.l10n.themeSystem,
      subtitle: context.l10n.themeSystemDesc,
      ),
      (
      mode: ThemeMode.light,
      icon: Icons.light_mode_rounded,
      title: context.l10n.themeLight,
      subtitle: context.l10n.themeLightDesc,
      ),
      (
      mode: ThemeMode.dark,
      icon: Icons.dark_mode_rounded,
      title: context.l10n.themeDark,
      subtitle: context.l10n.themeDarkDesc,
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
                    context.l10n.selectTheme,
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
