import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/widgets/current_state_card.dart';
import 'package:manager/services/system_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Perfiles extends StatefulWidget {
  const Perfiles({super.key});

  @override
  State<Perfiles> createState() => _PerfilesState();
}

class _PerfilesState extends State<Perfiles> {
  final SystemService _systemService = SystemService();
  String _currentProfile = '';
  List<String> profiles = ['performance', 'balanced', 'powersave'];

  @override
  void initState() {
    super.initState();
    _getCurrentProfile();
  }

  Future<void> _getCurrentProfile() async {
    final profile = await _systemService.getCurrentProfile();
    setState(() {
      _currentProfile = profile.trim();
    });
  }

  Future<void> _setProfile(String profile) async {
    try {
      await _systemService.setProfile(profile.toString().split('.').last);
      await _getCurrentProfile();
    } catch (e) {
      _showErrorSnackBar();
    }
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocale.snackBarText.getString(context)),
        action: SnackBarAction(
          label: AppLocale.snackBarLabel.getString(context),
          onPressed: _launchUrl,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _launchUrl() async {
    final Uri _url =
        Uri.parse('https://github.com/JUANIMAN/PerfMTK/releases/latest');
    try {
      await launchUrl(_url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocale.downloadMess.getString(context)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _getCurrentProfile();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocale.titleProfiles.getString(context),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              CurrentStateCard(
                state: _currentProfile.toString().split('.').last,
                icon: _getProfileIcon(_currentProfile),
                color: _getProfileColor(_currentProfile),
                titleLocaleKey: 'currentProfile',
                stateLocaleKey: _currentProfile.toString().split('.').last,
              ),
              const SizedBox(height: 32),
              Text(
                AppLocale.changeProfile.getString(context),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ..._buildProfileButtons(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProfileButtons() {
    return profiles.map((profile) {
      final isSelected = _currentProfile == profile;
      final icon = _getProfileIcon(profile);
      final color = _getProfileColor(profile);

      return _buildProfileButton(profile, isSelected, icon, color);
    }).toList();
  }

  Widget _buildProfileButton(
      String profile, bool isSelected, IconData icon, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isSelected
            ? null
            : () async {
                await _setProfile(profile);
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.getValue(profile).getString(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isSelected ? color : null,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getProfileDescription(profile),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color),
            ],
          ),
        ),
      ),
    );
  }

  String _getProfileDescription(String profile) {
    switch (profile) {
      case 'performance':
        return AppLocale.performance.getString(context);
      case 'balanced':
        return AppLocale.balanced.getString(context);
      case 'powersave':
        return AppLocale.powersave.getString(context);
      default:
        return '';
    }
  }

  IconData _getProfileIcon(String profile) {
    switch (profile) {
      case 'performance':
        return Icons.speed;
      case 'balanced':
        return Icons.balance;
      case 'powersave':
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
      default:
        return Colors.grey;
    }
  }
}
