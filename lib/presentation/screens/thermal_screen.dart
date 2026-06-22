import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/presentation/providers/system_provider.dart';
import 'package:manager/presentation/widgets/thermal_switch.dart';
import 'package:manager/config/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ThermalScreen extends ConsumerStatefulWidget {
  const ThermalScreen({super.key});

  @override
  ConsumerState<ThermalScreen> createState() => _ThermalScreenState();
}

class _ThermalScreenState extends ConsumerState<ThermalScreen>
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
    final isChanging = ref.watch(isChangingThermalProvider);
    final isEnabled = state.thermalState == ThermalState.enabled;

    return RefreshIndicator(
      onRefresh: () => ref.read(systemStateProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: AppConstants.paddingNormal,
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocale.titleThermal.getString(context),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  Text(
                    AppLocale.thermalControl.getString(context),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spacing24),

                  // ── Thermal switch ────────────────────────────────────────
                  IgnorePointer(
                    ignoring: isChanging,
                    child: AnimatedOpacity(
                      duration: AppConstants.animationFast,
                      opacity:
                          isChanging ? AppConstants.opacityDisabled : 1.0,
                      child: ThermalSwitch(
                        key: ValueKey(state.thermalState),
                        isEnabled: isEnabled,
                        onChanged: (value) =>
                            _setThermalLimit(value),
                      ),
                    ),
                  ),

                  // Loading indicator below the card
                  if (isChanging) ...[
                    const SizedBox(height: AppConstants.spacing16),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacing8),
                          Text(
                            AppLocale.applying.getString(context),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

  void _setThermalLimit(bool enabled) {
    HapticFeedback.mediumImpact();
    final thermalState =
        enabled ? ThermalState.enabled : ThermalState.disabled;
    ref.read(systemStateProvider.notifier).setThermalState(thermalState);
  }

  Future<void> _launchUrl() async {
    final uri =
        Uri.parse('https://github.com/JUANIMAN/PerfMTK/releases/latest');
    try {
      await launchUrl(uri);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocale.downloadMess.getString(context))),
        );
      }
    }
  }
}