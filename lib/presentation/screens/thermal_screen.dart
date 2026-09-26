import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/presentation/providers/system_provider.dart';
import 'package:manager/presentation/widgets/thermal_switch.dart';
import 'package:manager/presentation/widgets/charge_bypass_card.dart';
import 'package:manager/presentation/widgets/battery_care_card.dart';
import 'package:manager/presentation/widgets/realtime_thermal_chart.dart';
import 'package:manager/presentation/widgets/thermal_guardian_card.dart';
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
    final isChangingBypass = ref.watch(isChangingChargeBypassProvider);
    final isChangingCare = ref.watch(isChangingBatteryCareProvider);
    final isChangingGuardian = ref.watch(isChangingThermalGuardianProvider);
    final isEnabled = state.thermalState == ThermalState.enabled;

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
              AppConstants.spacing8,
              AppConstants.spacing16,
              AppConstants.spacing24,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Realtime Continuous Thermal Telemetry Chart ─────────
                  RealtimeThermalChart(
                    socTempC: state.socTempC,
                    batteryTempC: state.batteryTempC,
                  ),
                  const SizedBox(height: AppConstants.spacing24),

                  // ── Thermal Guardian (Predictive Gaming Optimizer) ────────
                  IgnorePointer(
                    ignoring: isChangingGuardian,
                    child: AnimatedOpacity(
                      duration: AppConstants.animationFast,
                      opacity:
                          isChangingGuardian ? AppConstants.opacityDisabled : 1.0,
                      child: ThermalGuardianCard(
                        key: const ValueKey('thermal_guardian_card'),
                        isEnabled: state.thermalGuardianEnabled,
                        status: state.thermalGuardianStatus,
                        targetTempC: state.thermalGuardianTargetC,
                        currentClampStep: state.thermalGuardianClampStep,
                        maxSteps: state.thermalGuardianMaxSteps,
                        trend: state.thermalGuardianTrend,
                        currentSocTempC: state.socTempC,
                        isChanging: isChangingGuardian,
                        onToggle: (val) => _setThermalGuardian(
                          val,
                          targetTempC: state.thermalGuardianTargetC,
                          maxSteps: state.thermalGuardianMaxSteps,
                        ),
                        onSettingsChanged: (temp, steps) => _setThermalGuardian(
                          state.thermalGuardianEnabled,
                          targetTempC: temp,
                          maxSteps: steps,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing24),

                  // ── Thermal switch ────────────────────────────────────────
                  IgnorePointer(
                    ignoring: isChanging,
                    child: AnimatedOpacity(
                      duration: AppConstants.animationFast,
                      opacity: isChanging ? AppConstants.opacityDisabled : 1.0,
                      child: ThermalSwitch(
                        key: const ValueKey('thermal_switch'),
                        isEnabled: isEnabled,
                        onChanged: (value) => _setThermalLimit(value),
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
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppConstants.spacing24),

                  // ── Smart Fast Charge Bypass ──────────────────────────────
                  IgnorePointer(
                    ignoring: isChangingBypass,
                    child: AnimatedOpacity(
                      duration: AppConstants.animationFast,
                      opacity:
                          isChangingBypass ? AppConstants.opacityDisabled : 1.0,
                      child: ChargeBypassCard(
                        key: const ValueKey('charge_bypass_card'),
                        isEnabled: state.chargeBypass,
                        batteryTempC: state.batteryTempC,
                        isChanging: isChangingBypass,
                        onChanged: (value) => _setChargeBypass(value),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacing24),

                  // ── Battery Health Care (80% Cut-off) ─────────────────────
                  IgnorePointer(
                    ignoring: isChangingCare,
                    child: AnimatedOpacity(
                      duration: AppConstants.animationFast,
                      opacity:
                          isChangingCare ? AppConstants.opacityDisabled : 1.0,
                      child: BatteryCareCard(
                        key: const ValueKey('battery_care_card'),
                        isEnabled: state.batteryCareEnabled,
                        limitPct: state.batteryCareLimitPct,
                        isSuspended: state.batteryCareSuspended,
                        currentCapacity: state.batteryCapacityPct,
                        isChanging: isChangingCare,
                        onToggle: (val) =>
                            _setBatteryCare(val, state.batteryCareLimitPct),
                        onLimitChanged: (lim) =>
                            _setBatteryCare(state.batteryCareEnabled, lim),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacing80),
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

  Future<void> _setThermalLimit(bool enabled) async {
    final thermalState = enabled ? ThermalState.enabled : ThermalState.disabled;
    try {
      await ref
          .read(systemStateProvider.notifier)
          .setThermalState(thermalState);
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

  Future<void> _setChargeBypass(bool enabled) async {
    try {
      await ref.read(systemStateProvider.notifier).setChargeBypass(enabled);
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

  Future<void> _setBatteryCare(bool enabled, int limitPct) async {
    try {
      await ref
          .read(systemStateProvider.notifier)
          .setBatteryCare(enabled, limitPct);
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

  Future<void> _setThermalGuardian(
    bool enabled, {
    int? targetTempC,
    int? maxSteps,
  }) async {
    try {
      await ref
          .read(systemStateProvider.notifier)
          .setThermalGuardian(
            enabled,
            targetTempC: targetTempC,
            maxSteps: maxSteps,
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
