import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/features/system/data/models/system_state.dart';
import 'package:manager/core/ui/action_runner.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/perf_config/presentation/perf_config_provider.dart';
import 'package:manager/features/system/presentation/system_provider.dart';
import 'package:manager/features/battery/presentation/widgets/battery_care_card.dart';
import 'package:manager/features/battery/presentation/widgets/battery_health_card.dart';
import 'package:manager/features/battery/presentation/widgets/charge_bypass_card.dart';
import 'package:manager/features/battery/presentation/widgets/charge_speed_card.dart';
import 'package:manager/features/battery/presentation/widgets/thermal_switch.dart';
import 'package:manager/features/battery/presentation/widgets/live_battery_hero_card.dart';

class BatteryScreen extends ConsumerStatefulWidget {
  const BatteryScreen({super.key});

  @override
  ConsumerState<BatteryScreen> createState() => _BatteryScreenState();
}

class _BatteryScreenState extends ConsumerState<BatteryScreen> {
  /// Runs a daemon action, surfacing failures to the user.
  void _run(Future<void> Function() action) =>
      unawaited(runUiAction(context, action));

  @override
  Widget build(BuildContext context) {
    final systemState = ref.watch(systemStateProvider);

    return Scaffold(
      body: systemState.when(
        data: (state) => _buildContent(state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorView(error),
      ),
    );
  }

  Widget _buildContent(SystemState state) {
    final hasHardwareBypass =
        ref.watch(deviceConfigProvider).value?.hasHardwareBypass ?? false;
    final isChangingBypass = ref.watch(isChangingChargeBypassProvider);
    final isChangingCare = ref.watch(isChangingBatteryCareProvider);
    final isChangingSpeed = ref.watch(isChangingChargeCurrentLimitProvider);
    final isChangingThermal = ref.watch(isChangingThermalProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(systemStateProvider.notifier).refresh(),
      child: CustomScrollView(
        key: const PageStorageKey('battery_scroll_view'),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              AppConstants.spacing8,
              AppConstants.spacing16,
              AppConstants.spacing80 + AppConstants.spacing24,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Live Hero Battery Card ──────────────────────────
                  LiveBatteryHeroCard(
                    state: state,
                    hasHardwareBypass: hasHardwareBypass,
                  ),
                  const SizedBox(height: AppConstants.spacing20),

                  // ── 2. Battery Health & BMS Longevity ──────────────────
                  BatteryHealthCard(
                    key: const ValueKey('battery_screen_health_card'),
                    state: state,
                  ),
                  const SizedBox(height: AppConstants.spacing20),

                  // ── 3. Charging Current / Speed Regulator ─────────────
                  ChargeSpeedCard(
                    currentLimitMa: state.chargeCurrentLimitMa ?? 0,
                    liveCurrentMa: state.chargeCurrentNowMa,
                    isChanging: isChangingSpeed,
                    onLimitChanged: (ma) {
                      _run(() => ref.read(systemStateProvider.notifier).setChargeCurrentLimit(ma));
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing20),

                  // ── 3. Battery Health Care (Cut-off) ───────────────────
                  BatteryCareCard(
                    key: const ValueKey('battery_screen_care_card'),
                    isEnabled: state.batteryCareEnabled,
                    limitPct: state.batteryCareLimitPct,
                    isSuspended: state.batteryCareSuspended,
                    currentCapacity: state.batteryCapacityPct,
                    isChanging: isChangingCare,
                    onToggle: (enabled) {
                      HapticFeedback.selectionClick();
                      _run(() => ref.read(systemStateProvider.notifier).setBatteryCare(
                            enabled,
                            state.batteryCareLimitPct,
                          ));
                    },
                    onLimitChanged: (limit) {
                      HapticFeedback.lightImpact();
                      _run(() => ref.read(systemStateProvider.notifier).setBatteryCare(
                            state.batteryCareEnabled,
                            limit,
                          ));
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing20),

                  // ── 4. Smart Fast Charge Bypass (Gaming / Direct Power) ─
                  ChargeBypassCard(
                    key: const ValueKey('battery_screen_bypass_card'),
                    isEnabled: state.chargeBypass,
                    hasHardwareBypass: hasHardwareBypass,
                    batteryTempC: state.batteryTempC,
                    isChanging: isChangingBypass,
                    onChanged: (enabled) {
                      _run(() => ref.read(systemStateProvider.notifier).setChargeBypass(enabled));
                    },
                  ),
                  const SizedBox(height: AppConstants.spacing20),

                  // ── 5. Control Térmico del Sistema (mi_thermald) ────────
                  ThermalSwitch(
                    key: const ValueKey('battery_screen_thermal_switch'),
                    isEnabled: state.thermalState == ThermalState.enabled,
                    isChanging: isChangingThermal,
                    onChanged: (enabled) {
                      final target =
                          enabled ? ThermalState.enabled : ThermalState.disabled;
                      _run(() => ref.read(systemStateProvider.notifier).setThermalState(target));
                    },
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
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              context.l10n.errorLoadingBattery('$error'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacing16),
            FilledButton.tonal(
              onPressed: () => ref.read(systemStateProvider.notifier).refresh(),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
