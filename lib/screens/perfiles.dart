import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/services/system_service.dart';
import 'package:manager/widgets/current_state_card.dart';
import 'package:manager/widgets/profile_button.dart';
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
      await _systemService.setProfile(profile);
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
      ),
    );
  }

  Future<void> _launchUrl() async {
    final Uri _url = Uri.parse('https://github.com/JUANIMAN/PerfMTK/releases/latest');
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
      onRefresh: _getCurrentProfile,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
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
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final profile = profiles[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ProfileButton(
                    profile: profile,
                    isSelected: _currentProfile == profile,
                    icon: _getProfileIcon(profile),
                    color: _getProfileColor(profile),
                    onTap: () => _setProfile(profile),
                  ),
                );
              },
              childCount: profiles.length,
            ),
          ),
        ],
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