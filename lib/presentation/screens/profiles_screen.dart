import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/presentation/providers/system_provider.dart';
import 'package:manager/presentation/widgets/current_state_card.dart';
import 'package:manager/presentation/widgets/profile_button.dart';
import 'package:manager/config/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemState = ref.watch(systemStateProvider);

    return Scaffold(
      body: systemState.when(
        data: (state) => _buildContent(context, ref, state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorView(context, ref, error),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, SystemState state) {
    final isChanging = ref.watch(isChangingProfileProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppConstants.paddingNormal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocale.titleProfiles.getString(context),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),
              CurrentStateCard(
                state: state.currentProfile.value,
                icon: _getProfileIcon(state.currentProfile),
                color: _getProfileColor(state.currentProfile),
                titleLocaleKey: 'currentProfile',
                stateLocaleKey: state.currentProfile.value,
                descriptionLocaleKey:
                _getProfileDescriptionKey(state.currentProfile),
                isLoading: isChanging,
              ),
              const SizedBox(height: AppConstants.spacing32),
              Text(
                AppLocale.subtitleProfiles.getString(context),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        Expanded(
          child: AbsorbPointer(
            absorbing: isChanging,
            child: AnimatedOpacity(
              duration: AppConstants.animationFast,
              opacity: isChanging ? AppConstants.opacityDisabled : 1.0,
              child: ListView.builder(
                padding: AppConstants.paddingHorizontal,
                itemCount: ProfileType.values.length,
                itemBuilder: (context, index) {
                  final profile = ProfileType.values[index];
                  final isSelected = state.currentProfile == profile;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacing8,
                    ),
                    child: ProfileButton(
                      profile: profile.value,
                      isSelected: isSelected,
                      icon: _getProfileIcon(profile),
                      color: _getProfileColor(profile),
                      onTap: () => _setProfile(context, ref, profile),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            AppLocale.snackBarText.getString(context),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () => ref.refresh(systemStateProvider),
              ),
              const SizedBox(width: AppConstants.spacing8),
              OutlinedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: Text(AppLocale.snackBarLabel.getString(context)),
                onPressed: () => _launchUrl(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _setProfile(BuildContext context, WidgetRef ref, ProfileType profile) {
    HapticFeedback.mediumImpact();
    ref.read(systemStateProvider.notifier).setProfile(profile);
  }

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.parse('https://github.com/JUANIMAN/PerfMTK/releases/latest');
    try {
      await launchUrl(uri);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocale.downloadMess.getString(context))),
        );
      }
    }
  }

  IconData _getProfileIcon(ProfileType profile) {
    switch (profile) {
      case ProfileType.performance:
        return Icons.speed;
      case ProfileType.balanced:
        return Icons.balance;
      case ProfileType.powersave:
        return Icons.battery_full;
      case ProfileType.powersavePlus:
        return Icons.battery_saver;
    }
  }

  Color _getProfileColor(ProfileType profile) {
    switch (profile) {
      case ProfileType.performance:
        return Colors.orange;
      case ProfileType.balanced:
        return Colors.blue;
      case ProfileType.powersave:
        return Colors.green;
      case ProfileType.powersavePlus:
        return Colors.teal;
    }
  }

  String _getProfileDescriptionKey(ProfileType profile) {
    switch (profile) {
      case ProfileType.performance:
        return AppLocale.performanceCard;
      case ProfileType.balanced:
        return AppLocale.balancedCard;
      case ProfileType.powersave:
        return AppLocale.powersaveCard;
      case ProfileType.powersavePlus:
        return AppLocale.powersavePlusCard;
    }
  }
}