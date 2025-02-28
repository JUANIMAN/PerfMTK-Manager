import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/widgets/about_dialog.dart';
import 'package:provider/provider.dart';
import 'package:manager/config/theme_provider.dart';
import 'package:manager/localization/app_locales.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final FlutterLocalization localization = FlutterLocalization.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocale.settings.getString(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    title: AppLocale.appearance.getString(context),
                    icon: Icons.palette_outlined,
                    children: [
                      _buildThemeSelector(context, themeProvider),
                    ],
                  ),
                  _buildSection(
                    context,
                    title: AppLocale.language.getString(context),
                    icon: Icons.language_outlined,
                    children: [
                      _buildLanguageSelector(context, localization),
                    ],
                  ),
                  _buildSection(
                    context,
                    title: AppLocale.profileSettings.getString(context),
                    icon: Icons.tune_outlined,
                    children: [
                      _buildProfileSettings(context),
                    ],
                  ),
                  _buildSection(
                    context,
                    title: AppLocale.about.getString(context),
                    icon: Icons.info_outline,
                    children: [
                      _buildAboutTile(context),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required List<Widget> children,
        required IconData icon,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          themeProvider.themeMode == ThemeMode.dark
              ? Icons.dark_mode_outlined
              : Icons.light_mode_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        AppLocale.themeMode.getString(context),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _getThemeModeText(context, themeProvider.themeMode),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context, themeProvider),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, FlutterLocalization localization) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.language_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        AppLocale.language.getString(context),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _getLanguageText(context, localization.currentLocale as Locale),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context, localization),
    );
  }

  Widget _buildProfileSettings(BuildContext context) {
    final ValueNotifier<bool> isLocked = ValueNotifier<bool>(false);

    return Column(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: isLocked,
          builder: (context, value, child) {
            return SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.speed_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                AppLocale.lockFreq.getString(context),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                AppLocale.lockFreqDescription.getString(context),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              value: value,
              onChanged: (newValue) {
                isLocked.value = newValue;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.info_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(AppLocale.about.getString(context)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => CustomAboutDialog(),
        );
      },
    );
  }

  String _getThemeModeText(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return AppLocale.themeSystem.getString(context);
      case ThemeMode.light:
        return AppLocale.themeLight.getString(context);
      case ThemeMode.dark:
        return AppLocale.themeDark.getString(context);
    }
  }

  String _getLanguageText(BuildContext context, Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return 'Español';
      case 'en':
      default:
        return 'English';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocale.selectTheme.getString(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeModeText(context, mode)),
              value: mode,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, FlutterLocalization localization) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocale.selectLanguage.getString(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: localization.currentLocale?.languageCode,
              onChanged: (value) {
                if (value != null) {
                  localization.translate(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'es',
              groupValue: localization.currentLocale?.languageCode,
              onChanged: (value) {
                if (value != null) {
                  localization.translate(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
