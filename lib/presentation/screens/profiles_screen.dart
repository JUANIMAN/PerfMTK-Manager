import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/presentation/providers/system_provider.dart';
import 'package:manager/presentation/widgets/profile_button.dart';
import 'package:manager/presentation/widgets/profile_utils.dart';
import 'package:manager/config/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilesScreen extends ConsumerStatefulWidget {
  const ProfilesScreen({super.key});

  @override
  ConsumerState<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends ConsumerState<ProfilesScreen>
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
    final systemState = ref.watch(systemStateProvider);

    return Scaffold(
      body: buildWithEntryAnimation(
        systemState.when(
          data: (state) => _buildContent(state),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorView(error),
        ),
      ),
    );
  }

  Widget _buildContent(SystemState state) {
    final isChanging = ref.watch(isChangingProfileProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(systemStateProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              AppConstants.spacing16,
              AppConstants.spacing16,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocale.titleProfiles.getString(context),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  _CurrentProfileHeroCard(
                    state: state,
                    isChanging: isChanging,
                  ),
                  const SizedBox(height: AppConstants.spacing24),
                  Text(
                    AppLocale.subtitleProfiles.getString(context),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                ],
              ),
            ),
          ),

          // ── Profile list ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing16,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final profile = ProfileType.values[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.spacing12),
                    child: AbsorbPointer(
                      absorbing: isChanging,
                      child: AnimatedOpacity(
                        duration: AppConstants.animationFast,
                        opacity: isChanging ? AppConstants.opacityDisabled : 1.0,
                        child: ProfileButton(
                          profile: profile,
                          isSelected: state.currentProfile == profile,
                          onTap: () => _setProfile(profile),
                        ),
                      ),
                    ),
                  );
                },
                childCount: ProfileType.values.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacing80 + AppConstants.spacing16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(Object error) {
    return Center(
      child: Padding(
        padding: AppConstants.paddingNormal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: AppConstants.spacing20),
            Text(
              AppLocale.snackBarText.getString(context),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConstants.spacing24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  onPressed: () => ref.refresh(systemStateProvider),
                ),
                const SizedBox(width: AppConstants.spacing12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(AppLocale.snackBarLabel.getString(context)),
                  onPressed: () => _launchUrl(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setProfile(ProfileType profile) {
    HapticFeedback.mediumImpact();
    ref.read(systemStateProvider.notifier).setProfile(profile);
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse('https://github.com/JUANIMAN/PerfMTK/releases/latest');
    try {
      await launchUrl(uri);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocale.downloadMess.getString(context))),
        );
      }
    }
  }
}

// ── Hero status card ──────────────────────────────────────────────────────────
class _CurrentProfileHeroCard extends StatelessWidget {
  final SystemState state;
  final bool isChanging;

  const _CurrentProfileHeroCard({
    required this.state,
    required this.isChanging,
  });

  @override
  Widget build(BuildContext context) {
    final profile = state.currentProfile;
    final color = ProfileUtils.colorFor(profile);
    final gradient = ProfileUtils.gradientFor(profile);
    final icon = ProfileUtils.iconFor(profile);

    return AnimatedContainer(
      duration: AppConstants.animationNormal,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  ),
                  child: isChanging
                      ? SizedBox(
                          width: AppConstants.iconSizeXLarge,
                          height: AppConstants.iconSizeXLarge,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Icon(
                          icon,
                          size: AppConstants.iconSizeXLarge,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocale.currentProfile.getString(context),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      AnimatedSwitcher(
                        duration: AppConstants.animationNormal,
                        child: Text(
                          isChanging
                              ? AppLocale.applying.getString(context)
                              : profile.displayName,
                          key: ValueKey(isChanging ? 'loading' : profile.value),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
