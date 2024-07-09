import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/widgets/current_state_card.dart';
import 'package:url_launcher/url_launcher.dart';

class Perfiles extends StatefulWidget {
  const Perfiles({super.key});

  @override
  State<Perfiles> createState() => _PerfilesState();
}

class _PerfilesState extends State<Perfiles> {
  final Uri _url = Uri.parse('https://github.com/JUANIMAN/PerfMTK/releases');
  String _currentProfile = '';

  @override
  void initState() {
    super.initState();
    _getCurrentProfile();
  }

  Future<void> _getCurrentProfile() async {
    final process = await Process.run('getprop', ['sys.perfmtk.current_profile']);
    final output = process.stdout as String;

    setState(() {
      _currentProfile = output.trim();
    });
  }

  Future<void> _setProfile(String profile) async {
    try {
      await Process.run('su', ['-c', 'perfmtk', profile]);
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
          onPressed: () {
            _launchUrl();
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _launchUrl() async {
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
    return SingleChildScrollView(
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
              state: _currentProfile,
              icon: _getProfileIcon(_currentProfile),
              color: _getProfileColor(_currentProfile),
              titleLocaleKey: 'currentProfile',
              stateLocaleKey: _currentProfile,
            ),
            const SizedBox(height: 32),
            Text(
              AppLocale.changeProfile.getString(context),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildProfileButton(context, 'performance', Icons.speed, Colors.orange),
            const SizedBox(height: 16),
            _buildProfileButton(context, 'balanced', Icons.balance, Colors.blue),
            const SizedBox(height: 16),
            _buildProfileButton(context, 'powersave', Icons.battery_saver, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context, String profile, IconData icon, Color color) {
    final isSelected = _currentProfile == profile;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isSelected ? null : () async {
            await _setProfile(profile);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    AppLocale.getValue(profile).getString(context),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected ? color : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected) Icon(Icons.check_circle, color: color),
              ],
            ),
          ),
        ),
      ),
    );
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
