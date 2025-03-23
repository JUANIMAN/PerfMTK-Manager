import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/services/system_service.dart';
import 'package:manager/services/app_profile_service.dart';
import 'package:manager/widgets/current_state_card.dart';
import 'package:manager/widgets/profile_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Profiles extends StatelessWidget {
  const Profiles({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemService>(
      builder: (context, systemService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocale.titleProfiles.getString(context),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  CurrentStateCard(
                    state: systemService.currentProfile,
                    icon: _getProfileIcon(systemService.currentProfile),
                    color: _getProfileColor(systemService.currentProfile),
                    titleLocaleKey: 'currentProfile',
                    stateLocaleKey: systemService.currentProfile,
                    descriptionLocaleKey: _getProfileDsc(systemService.currentProfile),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    AppLocale.subtitleProfiles.getString(context),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final profile = [
                    'performance',
                    'balanced',
                    'powersave',
                    'powersave+'
                  ][index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ProfileButton(
                      profile: profile,
                      isSelected: systemService.currentProfile == profile,
                      icon: _getProfileIcon(profile),
                      color: _getProfileColor(profile),
                      onTap: () => _setProfile(context, profile),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _setProfile(BuildContext context, String profile) async {
    try {
      final appProfileService = context.read<AppProfileService>();
      final appProfileExist = await appProfileService.checkConfigExists();

      if (appProfileExist) {
        await appProfileService.loadAppProfiles();
        await appProfileService.setDefaultProfile(profile);
      }

      await context.read<SystemService>().setProfile(profile, appProfileExist);
    } catch (e) {
      _showErrorSnackBar(context);
    }
  }

  void _showErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocale.snackBarText.getString(context)),
        action: SnackBarAction(
          label: AppLocale.snackBarLabel.getString(context),
          onPressed: () => _launchUrl(context),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context) async {
    final Uri url =
        Uri.parse('https://github.com/JUANIMAN/PerfMTK/releases/latest');
    try {
      await launchUrl(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocale.downloadMess.getString(context)),
        ),
      );
    }
  }

  IconData _getProfileIcon(String profile) {
    switch (profile) {
      case 'performance':
        return Icons.speed;
      case 'balanced':
        return Icons.balance;
      case 'powersave':
        return Icons.battery_full;
      case 'powersave+':
        return Icons.battery_saver;
      default:
        return Icons.help_outline;
    }
  }

  Color _getProfileColor(String profile) {
    switch (profile) {
      case 'performance':
        return Colors.orange;
      case 'balanced':
        return Colors.blue;
      case 'powersave':
        return Colors.green;
      case 'powersave+':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getProfileDsc(String profile) {
    switch (profile) {
      case 'performance':
        return AppLocale.performanceCard;
      case 'balanced':
        return AppLocale.balancedCard;
      case 'powersave':
        return AppLocale.powersaveCard;
      case 'powersave+':
        return AppLocale.powersavePlusCard;
      default:
        return '';
    }
  }
}
