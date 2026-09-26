import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/presentation/providers/system_provider.dart';
import 'package:manager/presentation/widgets/profile_button.dart';
import 'package:manager/presentation/widgets/profile_utils.dart';
import 'package:manager/presentation/widgets/hardware_telemetry_card.dart';
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
    final isLoading = ref.watch(
      systemStateProvider.select((s) => s.isLoading && !s.hasValue),
    );
    final error = ref.watch(
      systemStateProvider.select(
        (s) => s.hasError && !s.hasValue ? s.error : null,
      ),
    );

    return Scaffold(
      body: buildWithEntryAnimation(
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _buildErrorView(error)
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
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
              AppConstants.spacing24,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Banner de Estado Activo
                  const _ActiveProfileBanner(),
                  const SizedBox(height: AppConstants.spacing20),

                  // 2. Selector Táctil de Perfiles 2x2
                  _buildSectionHeader(
                    context,
                    AppLocale.switchProfileHeader.getString(context),
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  _ProfileGridSection(onSelectProfile: _setProfile),
                  const SizedBox(height: AppConstants.spacing20),

                  // 3. Monitor de Hardware en Vivo
                  const _HardwareTelemetrySection(),
                  const SizedBox(
                    height: AppConstants.spacing80 + AppConstants.spacing16,
                  ),
                ],
              ),
            ),
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
                  label: Text(AppLocale.retry.getString(context)),
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

  Future<void> _setProfile(ProfileType profile) async {
    try {
      await ref.read(systemStateProvider.notifier).setProfile(profile);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocale.profileApplied
                  .getString(context)
                  .replaceAll(
                    '{profile}',
                    ProfileUtils.nameFor(context, profile),
                  ),
            ),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(AppLocale.snackBarText.getString(context)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(
      'https://github.com/JUANIMAN/PerfMTK/releases/latest',
    );
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

Widget _buildSectionHeader(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(
              alpha: 0.8,
            ),
      ),
    ),
  );
}

// ── Profile Grid Section ────────────────────────────────────────────────────
class _ProfileGridSection extends ConsumerWidget {
  final Future<void> Function(ProfileType) onSelectProfile;

  const _ProfileGridSection({required this.onSelectProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentProfile = ref.watch(
      systemStateProvider.select(
        (s) => s.value?.currentProfile ?? ProfileType.balanced,
      ),
    );
    final isChanging = ref.watch(isChangingProfileProvider);

    return AbsorbPointer(
      absorbing: isChanging,
      child: AnimatedOpacity(
        duration: AppConstants.animationFast,
        opacity: isChanging ? AppConstants.opacityDisabled : 1.0,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ProfileButton(
                    profile: ProfileType.performance,
                    isSelected: currentProfile == ProfileType.performance,
                    onTap: () => onSelectProfile(ProfileType.performance),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing10),
                Expanded(
                  child: ProfileButton(
                    profile: ProfileType.balanced,
                    isSelected: currentProfile == ProfileType.balanced,
                    onTap: () => onSelectProfile(ProfileType.balanced),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing10),
            Row(
              children: [
                Expanded(
                  child: ProfileButton(
                    profile: ProfileType.powersave,
                    isSelected: currentProfile == ProfileType.powersave,
                    onTap: () => onSelectProfile(ProfileType.powersave),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing10),
                Expanded(
                  child: ProfileButton(
                    profile: ProfileType.powersavePlus,
                    isSelected: currentProfile == ProfileType.powersavePlus,
                    onTap: () => onSelectProfile(ProfileType.powersavePlus),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hardware Telemetry Section ──────────────────────────────────────────────
class _HardwareTelemetrySection extends ConsumerWidget {
  const _HardwareTelemetrySection();

  static bool hasTelemetry(SystemState s) =>
      s.cpuClusters.isNotEmpty ||
      s.gpuFreq.isNotEmpty ||
      s.dramFreq.isNotEmpty ||
      s.socTempC != null ||
      s.batteryTempC != null ||
      s.chargeBypass ||
      s.batteryCapacityPct != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(systemStateProvider).value;
    if (state == null || !hasTelemetry(state)) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          AppLocale.hardwareMonitorHeader.getString(context),
        ),
        const SizedBox(height: AppConstants.spacing8),
        HardwareTelemetryCard(state: state),
      ],
    );
  }
}

// ── Active Profile Banner ───────────────────────────────────────────────────
class _ActiveProfileBanner extends ConsumerWidget {
  const _ActiveProfileBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(
      systemStateProvider.select(
        (s) => s.value?.currentProfile ?? ProfileType.balanced,
      ),
    );
    final app = ref.watch(
      systemStateProvider.select(
        (s) => s.value?.currentApp ?? '',
      ),
    );
    final isChanging = ref.watch(isChangingProfileProvider);

    final color = ProfileUtils.colorForContext(context, profile);
    final icon = ProfileUtils.iconFor(profile);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(
          color: color.withValues(alpha: 0.40),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: isChanging
                ? SizedBox(
                    width: AppConstants.iconSizeLarge,
                    height: AppConstants.iconSizeLarge,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  )
                : Icon(icon, color: color, size: AppConstants.iconSizeLarge),
          ),
          const SizedBox(width: AppConstants.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocale.currentProfile.getString(context).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedSwitcher(
                  duration: AppConstants.animationNormal,
                  child: Text(
                    isChanging
                        ? AppLocale.applying.getString(context)
                        : ProfileUtils.nameFor(context, profile),
                    key: ValueKey(isChanging ? 'loading' : profile.value),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // App Context Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.25),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isGlobalApp(app)
                      ? Icons.public_rounded
                      : Icons.sports_esports_rounded,
                  size: 13,
                  color: color,
                ),
                const SizedBox(width: 5),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 110),
                  child: Text(
                    _displayAppName(context, app),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isGlobalApp(String app) =>
      app.isEmpty || app == 'com.perfmtk.manager';

  String _displayAppName(BuildContext context, String app) {
    if (_isGlobalApp(app)) return AppLocale.modeGlobal.getString(context);
    return app;
  }
}
