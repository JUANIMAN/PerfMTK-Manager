import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/data/models/device_config.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/profile_config.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/providers/perf_config_provider.dart';
import 'package:manager/presentation/widgets/perf_config/charge_thermal_card.dart';
import 'package:manager/presentation/widgets/perf_config/cpu_policy_card.dart';
import 'package:manager/presentation/widgets/perf_config/devfreq_card.dart';
import 'package:manager/presentation/widgets/perf_config/fpsgo_card.dart';
import 'package:manager/presentation/widgets/perf_config/gbe_card.dart';
import 'package:manager/presentation/widgets/perf_config/gpu_card.dart';
import 'package:manager/presentation/widgets/perf_config/profile_save_fab.dart';
import 'package:manager/presentation/widgets/perf_config/rate_limits_card.dart';
import 'package:manager/presentation/widgets/perf_config/touch_card.dart';
import 'package:manager/presentation/widgets/perf_config/uclamp_card.dart';
import 'package:manager/presentation/widgets/perf_config/ufs_card.dart';
import 'package:manager/presentation/widgets/profile_utils.dart';

/// Body for each profile tab showing all configurable hardware subsystems.
class ProfileTabBody extends ConsumerStatefulWidget {
  final ProfileType profile;
  const ProfileTabBody({super.key, required this.profile});

  @override
  ConsumerState<ProfileTabBody> createState() => _ProfileTabBodyState();
}

class _ProfileTabBodyState extends ConsumerState<ProfileTabBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static ProfileConfig _normalizeWithDevice(
    ProfileConfig config,
    DeviceConfig device,
  ) {
    final policies = device.policies;
    if (policies.isEmpty) return config;

    final needsMin = config.cpu.minFreqs.length != policies.length ||
        config.cpu.minFreqs.any((f) => f <= 0);
    final needsMax = config.cpu.maxFreqs.length != policies.length ||
        config.cpu.maxFreqs.any((f) => f <= 0);
    final needsGovs = config.cpu.governors.length != policies.length ||
        config.cpu.governors.any((g) => g.isEmpty);
    final needsCore = config.cpu.coreConfig.length != policies.length ||
        config.cpu.coreConfig.any((c) => !c.cpuId.startsWith('cpu'));

    if (!needsMin && !needsMax && !needsGovs && !needsCore) {
      return config;
    }

    final normalizedMin = List<int>.generate(policies.length, (idx) {
      if (idx < config.cpu.minFreqs.length && config.cpu.minFreqs[idx] > 0) {
        return config.cpu.minFreqs[idx];
      }
      return policies[idx].minFreq;
    });

    final normalizedMax = List<int>.generate(policies.length, (idx) {
      if (idx < config.cpu.maxFreqs.length && config.cpu.maxFreqs[idx] > 0) {
        return config.cpu.maxFreqs[idx];
      }
      return policies[idx].maxFreq;
    });

    final normalizedGovs = List<String>.generate(policies.length, (idx) {
      if (idx < config.cpu.governors.length &&
          config.cpu.governors[idx].isNotEmpty) {
        return config.cpu.governors[idx];
      }
      return policies[idx].governors.isNotEmpty
          ? policies[idx].governors.first
          : 'schedutil';
    });

    final normalizedCore = List<CoreClusterConfig>.generate(policies.length, (idx) {
      final pol = policies[idx];
      final cpuId = pol.cpus.isNotEmpty ? 'cpu${pol.cpus.first}' : 'cpu$idx';
      final totCores = pol.cpus.length;
      if (idx < config.cpu.coreConfig.length &&
          config.cpu.coreConfig[idx].cpuId.startsWith('cpu') &&
          config.cpu.coreConfig[idx].totalCores == totCores) {
        return config.cpu.coreConfig[idx];
      }
      return CoreClusterConfig(
        cpuId: cpuId,
        totalCores: totCores,
        onlineCores: totCores,
      );
    });

    return config.copyWith(
      cpu: config.cpu.copyWith(
        minFreqs: normalizedMin,
        maxFreqs: normalizedMax,
        governors: normalizedGovs,
        coreConfig: normalizedCore,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final deviceAsync = ref.watch(deviceConfigProvider);
    final configAsync = ref.watch(profileConfigProvider(widget.profile));
    final editorState = ref.watch(profileEditorProvider(widget.profile));

    return deviceAsync.when(
      data: (device) => configAsync.when(
        data: (loadedConfig) {
          final normalizedSaved = _normalizeWithDevice(loadedConfig, device);
          // One-shot initialization of the editor state
          if (editorState.config == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ref
                  .read(profileEditorProvider(widget.profile).notifier)
                  .initialize(normalizedSaved);
            });
            return const Center(child: CircularProgressIndicator());
          }

          return _buildContent(context, ref, device, editorState, normalizedSaved);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(context, ref, e),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildError(context, ref, e),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    DeviceConfig device,
    ProfileEditorState editorState,
    ProfileConfig savedConfig,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = editorState.config!;
    final profile = widget.profile;
    final profileColor = ProfileUtils.colorFor(profile, isDark: isDark);
    final notifier = ref.read(profileEditorProvider(profile).notifier);

    return Stack(
      children: [
        // ── Scrollable content ───────────────────────────────────────────
        RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(deviceConfigProvider);
            final dev = await ref.read(deviceConfigProvider.future);
            ref.invalidate(profileConfigProvider(profile));
            final saved = await ref.read(profileConfigProvider(profile).future);
            final latestEditor = ref.read(profileEditorProvider(profile));
            if (!latestEditor.isDirty) notifier.revert(_normalizeWithDevice(saved, dev));
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacing16,
                  AppConstants.spacing12,
                  AppConstants.spacing16,
                  0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    _buildSections(
                      context,
                      device,
                      config,
                      notifier,
                      profileColor,
                    ),
                  ),
                ),
              ),
              // Bottom padding behind the nav bar + FAB
              const SliverToBoxAdapter(
                child: SizedBox(
                  height:
                      AppConstants.spacing80 +
                      AppConstants.spacing80 +
                      AppConstants.spacing16,
                ),
              ),
            ],
          ),
        ),

        // ── Save FAB ─────────────────────────────────────────────────────
        AnimatedPositioned(
          duration: AppConstants.animationNormal,
          curve: Curves.easeOutCubic,
          bottom: editorState.isDirty
              ? AppConstants.spacing80 + AppConstants.spacing16
              : -80,
          right: AppConstants.spacing16,
          child: ProfileSaveFab(
            profile: profile,
            editorState: editorState,
            savedConfig: savedConfig,
            color: profileColor,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSections(
    BuildContext context,
    DeviceConfig device,
    ProfileConfig config,
    ProfileEditorNotifier notifier,
    Color profileColor,
  ) {
    final sections = <Widget>[];

    // ── CPU section label ────────────────────────────────────────────────
    sections.add(SectionLabel(label: 'CPU', color: profileColor));
    sections.add(const SizedBox(height: AppConstants.spacing8));

    // ── CPU cluster cards ────────────────────────────────────────────────
    for (final (i, policy) in device.policies.indexed) {
      final currentMin = (i < config.cpu.minFreqs.length && config.cpu.minFreqs[i] > 0)
          ? config.cpu.minFreqs[i]
          : policy.minFreq;
      final currentMax = (i < config.cpu.maxFreqs.length && config.cpu.maxFreqs[i] > 0)
          ? config.cpu.maxFreqs[i]
          : policy.maxFreq;
      final currentGov = (i < config.cpu.governors.length && config.cpu.governors[i].isNotEmpty)
          ? config.cpu.governors[i]
          : (policy.governors.isNotEmpty ? policy.governors.first : 'schedutil');
      final currentOnline = (i < config.cpu.coreConfig.length && config.cpu.coreConfig[i].cpuId.startsWith('cpu'))
          ? config.cpu.coreConfig[i].onlineCores
          : policy.cpus.length;
      final currentTotal = (i < config.cpu.coreConfig.length && config.cpu.coreConfig[i].cpuId.startsWith('cpu'))
          ? config.cpu.coreConfig[i].totalCores
          : policy.cpus.length;

      sections.add(
        CpuPolicyCard(
          policy: policy,
          policyIndex: i,
          currentMinFreq: currentMin,
          currentMaxFreq: currentMax,
          currentGovernor: currentGov,
          onlineCores: currentOnline,
          totalCores: currentTotal,
          onChanged:
              ({
                required int minFreq,
                required int maxFreq,
                required String governor,
                required int onlineCores,
              }) {
                final newMin = List<int>.generate(device.policies.length, (idx) {
                  if (idx == i) return minFreq;
                  if (idx < config.cpu.minFreqs.length && config.cpu.minFreqs[idx] > 0) {
                    return config.cpu.minFreqs[idx];
                  }
                  return device.policies[idx].minFreq;
                });

                final newMax = List<int>.generate(device.policies.length, (idx) {
                  if (idx == i) return maxFreq;
                  if (idx < config.cpu.maxFreqs.length && config.cpu.maxFreqs[idx] > 0) {
                    return config.cpu.maxFreqs[idx];
                  }
                  return device.policies[idx].maxFreq;
                });

                final newGovs = List<String>.generate(device.policies.length, (idx) {
                  if (idx == i) return governor;
                  if (idx < config.cpu.governors.length && config.cpu.governors[idx].isNotEmpty) {
                    return config.cpu.governors[idx];
                  }
                  return device.policies[idx].governors.isNotEmpty
                      ? device.policies[idx].governors.first
                      : 'schedutil';
                });

                final newCore = List<CoreClusterConfig>.generate(device.policies.length, (idx) {
                  final pol = device.policies[idx];
                  final cpuId = pol.cpus.isNotEmpty ? 'cpu${pol.cpus.first}' : 'cpu$idx';
                  final totCores = pol.cpus.length;
                  if (idx == i) {
                    return CoreClusterConfig(
                      cpuId: cpuId,
                      totalCores: totCores,
                      onlineCores: onlineCores.clamp(0, totCores),
                    );
                  }
                  if (idx < config.cpu.coreConfig.length &&
                      config.cpu.coreConfig[idx].cpuId.startsWith('cpu') &&
                      config.cpu.coreConfig[idx].totalCores == totCores) {
                    return config.cpu.coreConfig[idx];
                  }
                  return CoreClusterConfig(
                    cpuId: cpuId,
                    totalCores: totCores,
                    onlineCores: totCores,
                  );
                });

                notifier.update(
                  config.copyWith(
                    cpu: config.cpu.copyWith(
                      minFreqs: newMin,
                      maxFreqs: newMax,
                      governors: newGovs,
                      coreConfig: newCore,
                    ),
                  ),
                );
              },
        ),
      );
      sections.add(const SizedBox(height: AppConstants.spacing12));
    }

    // ── Rate limits card ────────────────────────────────────────────────────
    sections.add(
      RateLimitsCard(
        downRateLimitUs: config.cpu.downRateLimitUs,
        upRateLimitUs: config.cpu.upRateLimitUs,
        policies: device.policies,
        color: profileColor,
        onChanged: (down, up) {
          notifier.update(
            config.copyWith(
              cpu: config.cpu.copyWith(
                downRateLimitUs: down,
                upRateLimitUs: up,
              ),
            ),
          );
        },
      ),
    );

    if (device.hasUclamp) {
      sections.add(const SizedBox(height: AppConstants.spacing12));
      sections.add(
        UclampCard(
          minTopApp: config.uclamp.uclampMinTopApp,
          maxTopApp: config.uclamp.uclampMaxTopApp,
          minFg: config.uclamp.uclampMinFg,
          maxFg: config.uclamp.uclampMaxFg,
          color: profileColor,
          onChanged: ({
            required int minTopApp,
            required int maxTopApp,
            required int minFg,
            required int maxFg,
          }) {
            notifier.update(
              config.copyWith(
                uclamp: config.uclamp.copyWith(
                  uclampMinTopApp: minTopApp,
                  uclampMaxTopApp: maxTopApp,
                  uclampMinFg: minFg,
                  uclampMaxFg: maxFg,
                ),
              ),
            );
          },
        ),
      );
    }

    sections.add(const SizedBox(height: AppConstants.spacing20));

    // ── GPU ──────────────────────────────────────────────────────────────
    sections.add(SectionLabel(label: 'GPU', color: profileColor));
    sections.add(const SizedBox(height: AppConstants.spacing8));
    sections.add(
      GpuCard(
        gpuFreq: config.gpu.gpuFreq,
        gpuGovernor: config.gpu.gpuGovernor,
        gpuMinFreq: config.gpu.gpuMinFreq,
        gpuMaxFreq: config.gpu.gpuMaxFreq,
        availableFreqs: device.gpuFreqs,
        availableGovernors: device.gpuGovernors,
        hasGovernor: device.gpuHasGovernor,
        supportsMinMaxFreq: device.gpuSupportsMinMaxFreq,
        color: profileColor,
        onChanged: ({freq, governor, minFreq, maxFreq}) {
          notifier.update(
            config.copyWith(
              gpu: config.gpu.copyWith(
                gpuFreq: freq ?? config.gpu.gpuFreq,
                gpuGovernor: governor ?? config.gpu.gpuGovernor,
                gpuMinFreq: minFreq ?? config.gpu.gpuMinFreq,
                gpuMaxFreq: maxFreq ?? config.gpu.gpuMaxFreq,
              ),
            ),
          );
        },
      ),
    );

    // ── DEVFREQ ──────────────────────────────────────────────────────────
    if (device.dvfAvailable && device.dvfFreqs.isNotEmpty) {
      sections.add(const SizedBox(height: AppConstants.spacing20));
      sections.add(SectionLabel(label: 'DRAM DVFS', color: profileColor));
      sections.add(const SizedBox(height: AppConstants.spacing8));
      sections.add(
        DevfreqCard(
          dvfGovernor: config.devfreq.dvfGovernor,
          currentMinFreq: config.devfreq.dvfMinFreq,
          availableFreqs: device.dvfFreqs,
          availableGovernors: device.dvfGovernors,
          color: profileColor,
          onChanged: ({String? governor, int? minFreq}) {
            notifier.update(
              config.copyWith(
                devfreq: config.devfreq.copyWith(
                  dvfGovernor: governor ?? config.devfreq.dvfGovernor,
                  dvfMinFreq: minFreq ?? config.devfreq.dvfMinFreq,
                ),
              ),
            );
          },
        ),
      );
    }

    // ── UFS ──────────────────────────────────────────────────────────────
    if (device.ufsAvailable) {
      sections.add(const SizedBox(height: AppConstants.spacing20));
      sections.add(SectionLabel(label: 'UFS', color: profileColor));
      sections.add(const SizedBox(height: AppConstants.spacing8));
      sections.add(
        UfsCard(
          ufsGovernor: config.ufs.ufsGovernor,
          ufsClkEnable: config.ufs.ufsClkEnable,
          availableGovernors: device.ufsGovernors,
          color: profileColor,
          onChanged: (gov, clk) {
            notifier.update(
              config.copyWith(
                ufs: config.ufs.copyWith(ufsGovernor: gov, ufsClkEnable: clk),
              ),
            );
          },
        ),
      );
    }

    // ── FPSGO ────────────────────────────────────────────────────────────
    if (device.hasFpsgo) {
      sections.add(const SizedBox(height: AppConstants.spacing20));
      sections.add(SectionLabel(label: 'FPSGO', color: profileColor));
      sections.add(const SizedBox(height: AppConstants.spacing8));
      sections.add(
        FpsgoCard(
          forceOnOff: config.fpsgo.forceOnOff,
          boostTa: config.fpsgo.boostTa,
          color: profileColor,
          onChanged: (force, boost) {
            notifier.update(
              config.copyWith(
                fpsgo: config.fpsgo.copyWith(forceOnOff: force, boostTa: boost),
              ),
            );
          },
        ),
      );
    }

    // ── GBE (Game Turbo) ──────────────────────────────────────────────────
    if (device.hasGbe) {
      sections.add(const SizedBox(height: AppConstants.spacing20));
      sections.add(SectionLabel(label: 'Game Turbo', color: profileColor));
      sections.add(const SizedBox(height: AppConstants.spacing8));
      sections.add(
        GbeCard(
          gbeEnable: config.gbe.gbeEnable,
          gbeThrmHdrm: config.gbe.gbeThrmHdrm,
          color: profileColor,
          onChanged: (enable, thrmHdrm) {
            notifier.update(
              config.copyWith(
                gbe: config.gbe.copyWith(
                  gbeEnable: enable,
                  gbeThrmHdrm: thrmHdrm,
                ),
              ),
            );
          },
        ),
      );
    }

    // ── THERMAL & CHARGING ────────────────────────────────────────────────
    sections.add(const SizedBox(height: AppConstants.spacing20));
    sections.add(
      SectionLabel(
        label: AppLocale.thermalChargeTitle.getString(context),
        color: profileColor,
      ),
    );
    sections.add(const SizedBox(height: AppConstants.spacing8));
    sections.add(
      ChargeThermalCard(
        bypassChargeThrottle: config.chargeThermal.bypassChargeThrottle,
        unlockFpsThermal: config.chargeThermal.unlockFpsThermal,
        batteryTempLimit: config.chargeThermal.batteryTempLimit,
        color: profileColor,
        hasChargeBypass: device.hasChargeBypass,
        onChanged: ({
          required bool bypassChargeThrottle,
          required bool unlockFpsThermal,
          required int batteryTempLimit,
        }) {
          notifier.update(
            config.copyWith(
              chargeThermal: config.chargeThermal.copyWith(
                bypassChargeThrottle: bypassChargeThrottle,
                hardwareChargeBypass:
                    device.hasHardwareBypass ? bypassChargeThrottle : false,
                unlockFpsThermal: unlockFpsThermal,
                batteryTempLimit: batteryTempLimit,
              ),
            ),
          );
        },
      ),
    );

    // ── TOUCH & DIGITIZER BOOSTER ─────────────────────────────────────────
    sections.add(const SizedBox(height: AppConstants.spacing20));
    sections.add(
      SectionLabel(
        label: AppLocale.touchBoosterTitle.getString(context),
        color: profileColor,
      ),
    );
    sections.add(const SizedBox(height: AppConstants.spacing8));
    sections.add(
      TouchCard(
        gameMode: config.touch.gameMode,
        thpSmooth: config.touch.thpSmooth,
        color: profileColor,
        onChanged: ({
          required bool gameMode,
          required bool thpSmooth,
        }) {
          notifier.update(
            config.copyWith(
              touch: config.touch.copyWith(
                gameMode: gameMode,
                thpSmooth: thpSmooth,
              ),
            ),
          );
        },
      ),
    );

    return sections;
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: AppConstants.paddingNormal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing20),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: cs.error,
              ),
            ),
            Text(
              AppLocale.perfConfigError.getString(context),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConstants.spacing16),
            FilledButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocale.retry.getString(context)),
              onPressed: () {
                ref.invalidate(profileConfigProvider(widget.profile));
                ref.invalidate(deviceConfigProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const SectionLabel({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}
