import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/custom_selection_tile.dart';

class LanguageSelectionSheet extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageSelected;

  const LanguageSelectionSheet({
    super.key,
    required this.currentLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final languages = [
      (code: 'en', icon: '🇬🇧', title: 'English', subtitle: 'English'),
      (code: 'es', icon: '🇪🇸', title: 'Español', subtitle: 'Spanish'),
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
                    Icons.language_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppConstants.spacing12),
                  Text(
                    AppLocale.selectLanguage.getString(context),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing20),
            ...languages.map((lang) {
              final isSelected = currentLanguage == lang.code;
              return SelectionTile(
                iconText: lang.icon,
                title: lang.title,
                subtitle: lang.subtitle,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onLanguageSelected(lang.code);
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