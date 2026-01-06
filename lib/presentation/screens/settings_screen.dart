import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/presentation/widgets/about_dialog.dart';
import 'package:manager/config/theme_provider.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/presentation/widgets/language_selection_sheet.dart';
import 'package:manager/presentation/widgets/theme_selection_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
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
    final themeMode = ref.watch(themeModeProvider);
    final FlutterLocalization localization = FlutterLocalization.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocale.settings.getString(context),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          tooltip: 'Back',
        ),
      ),
      body: buildWithEntryAnimation(
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: AppConstants.paddingHorizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.spacing24),
                SectionHeader(
                  title: AppLocale.appearance.getString(context),
                  icon: Icons.palette_outlined,
                ),
                const SizedBox(height: AppConstants.spacing12),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildThemeSelector(context, ref, themeMode),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing24),
                SectionHeader(
                  title: AppLocale.language.getString(context),
                  icon: Icons.language_outlined,
                ),
                const SizedBox(height: AppConstants.spacing12),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildLanguageSelector(context, localization),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing24),
                SectionHeader(
                  title: AppLocale.about.getString(context),
                  icon: Icons.info_outline,
                ),
                const SizedBox(height: AppConstants.spacing12),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildAboutTile(context),
                  ],
                ),
                const SizedBox(height: AppConstants.spacing32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: Theme.of(context).dividerColor.light,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildThemeSelector(
      BuildContext context, WidgetRef ref, ThemeMode themeMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        onTap: () => _showThemeDialog(context, ref, themeMode),
        child: Padding(
          padding: AppConstants.paddingNormal,
          child: Row(
            children: [
              IconContainer(
                icon: themeMode == ThemeMode.dark
                    ? Icons.dark_mode_rounded
                    : themeMode == ThemeMode.light
                    ? Icons.light_mode_rounded
                    : Icons.brightness_auto_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppConstants.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.themeMode.getString(context),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      _getThemeModeText(context, themeMode),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
      BuildContext context, FlutterLocalization localization) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        onTap: () => _showLanguageDialog(context, localization),
        child: Padding(
          padding: AppConstants.paddingNormal,
          child: Row(
            children: [
              IconContainer(
                icon: Icons.language_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppConstants.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.language.getString(context),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      _getLanguageText(
                          context, localization.currentLocale as Locale),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        onTap: () {
          HapticFeedback.lightImpact();
          showDialog(
            context: context,
            builder: (context) => const CustomAboutDialog(),
          );
        },
        child: Padding(
          padding: AppConstants.paddingNormal,
          child: Row(
            children: [
              IconContainer(
                icon: Icons.info_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppConstants.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.about.getString(context),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      'PerfMTK Manager',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
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

  void _showThemeDialog(
      BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ThemeSelectionSheet(
        currentMode: currentMode,
        onThemeSelected: (mode) {
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, FlutterLocalization localization) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LanguageSelectionSheet(
        currentLanguage: localization.currentLocale?.languageCode ?? 'en',
        onLanguageSelected: (languageCode) {
          localization.translate(languageCode);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}