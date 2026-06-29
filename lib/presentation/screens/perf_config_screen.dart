import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/data/models/device_config.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/data/models/profile_config.dart';
import 'package:manager/presentation/providers/perf_config_provider.dart';
import 'package:manager/presentation/widgets/perf_config/cpu_policy_card.dart';
import 'package:manager/presentation/widgets/perf_config/devfreq_card.dart';
import 'package:manager/presentation/widgets/perf_config/fpsgo_card.dart';
import 'package:manager/presentation/widgets/perf_config/gpu_card.dart';
import 'package:manager/presentation/widgets/perf_config/section_card.dart';
import 'package:manager/presentation/widgets/perf_config/ufs_card.dart';
import 'package:manager/presentation/widgets/profile_utils.dart';
import 'package:manager/localization/app_locales.dart';

class PerfConfigScreen extends ConsumerStatefulWidget {
  const PerfConfigScreen({super.key});

  @override
  ConsumerState<PerfConfigScreen> createState() => _PerfConfigScreenState();
}

class _PerfConfigScreenState extends ConsumerState<PerfConfigScreen>
    with TickerProviderStateMixin, EntryAnimationMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ProfileType.values.length,
      vsync: this,
    );
    initEntryAnimation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    disposeEntryAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildWithEntryAnimation(
      Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacing16,
              AppConstants.spacing16,
              AppConstants.spacing16,
              AppConstants.spacing8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocale.titlePerfConfig.getString(context),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocale.perfConfigDescription.getString(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // ── Tab bar ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing16,
            ),
            child: _ProfileTabBar(controller: _tabController),
          ),
          const SizedBox(height: AppConstants.spacing8),
          const Divider(height: 1),

          // ── Tab views ──────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: ProfileType.values
                  .map((p) => _ProfileTabBody(profile: p))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile tab bar ───────────────────────────────────────────────────────────

class _ProfileTabBar extends StatelessWidget {
  final TabController controller;
  const _ProfileTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: false,
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.zero,
      indicator: const BoxDecoration(),
      dividerColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      tabs: ProfileType.values.map((p) {
        final color = ProfileUtils.colorFor(p);
        final icon = ProfileUtils.iconFor(p);
        return Tab(
          height: 48,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _TabChip(
              icon: icon,
              label: _shortName(p),
              color: color,
              controller: controller,
              index: ProfileType.values.indexOf(p),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _shortName(ProfileType p) {
    switch (p) {
      case ProfileType.performance:
        return 'Perf';
      case ProfileType.balanced:
        return 'Balanced';
      case ProfileType.powersave:
        return 'Save';
      case ProfileType.powersavePlus:
        return 'Save+';
    }
  }
}

class _TabChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final TabController controller;
  final int index;

  const _TabChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final selected = controller.index == index;
        return AnimatedContainer(
          duration: AppConstants.animationFast,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing8,
            vertical: AppConstants.spacing6,
          ),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.5)
                  : cs.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? color : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? color : cs.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Per-profile tab body ──────────────────────────────────────────────────────

class _ProfileTabBody extends ConsumerStatefulWidget {
  final ProfileType profile;
  const _ProfileTabBody({required this.profile});

  @override
  ConsumerState<_ProfileTabBody> createState() => _ProfileTabBodyState();
}

class _ProfileTabBodyState extends ConsumerState<_ProfileTabBody>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final deviceAsync = ref.watch(deviceConfigProvider);
    final configAsync = ref.watch(profileConfigProvider(widget.profile));
    final editorState = ref.watch(profileEditorProvider(widget.profile));

    return deviceAsync.when(
      data: (device) => configAsync.when(
        data: (loadedConfig) {
          // One-shot initialisation of the editor state
          if (editorState.config == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ref
                  .read(profileEditorProvider(widget.profile).notifier)
                  .initialize(loadedConfig);
            });
            return const Center(child: CircularProgressIndicator());
          }

          return _buildContent(context, ref, device, editorState, loadedConfig);
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
    final config = editorState.config!;
    final profile = widget.profile;
    final profileColor = ProfileUtils.colorFor(profile);
    final notifier = ref.read(profileEditorProvider(profile).notifier);

    return Stack(
      children: [
        // ── Scrollable content ───────────────────────────────────────────
        RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(profileConfigProvider(profile));
            ref.invalidate(deviceConfigProvider);
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
          child: _SaveFab(
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
    sections.add(_SectionLabel(label: 'CPU', color: profileColor));
    sections.add(const SizedBox(height: AppConstants.spacing8));

    // ── CPU cluster cards ────────────────────────────────────────────────
    for (final (i, policy) in device.policies.indexed) {
      sections.add(
        CpuPolicyCard(
          policy: policy,
          policyIndex: i,
          currentMinFreq: i < config.cpu.minFreqs.length
              ? config.cpu.minFreqs[i]
              : policy.minFreq,
          currentMaxFreq: i < config.cpu.maxFreqs.length
              ? config.cpu.maxFreqs[i]
              : policy.maxFreq,
          currentGovernor: i < config.cpu.governors.length
              ? config.cpu.governors[i]
              : (policy.governors.isNotEmpty
                    ? policy.governors.first
                    : 'schedutil'),
          onlineCores: i < config.cpu.coreConfig.length
              ? config.cpu.coreConfig[i].onlineCores
              : policy.cpus.length,
          totalCores: i < config.cpu.coreConfig.length
              ? config.cpu.coreConfig[i].totalCores
              : policy.cpus.length,
          onChanged:
              ({
                required int minFreq,
                required int maxFreq,
                required String governor,
                required int onlineCores,
              }) {
                final newMin = List<int>.from(config.cpu.minFreqs);
                final newMax = List<int>.from(config.cpu.maxFreqs);
                final newGovs = List<String>.from(config.cpu.governors);
                final newCore = List<CoreClusterConfig>.from(
                  config.cpu.coreConfig,
                );

                if (i < newMin.length) newMin[i] = minFreq;
                if (i < newMax.length) newMax[i] = maxFreq;
                if (i < newGovs.length) newGovs[i] = governor;
                if (i < newCore.length) {
                  newCore[i] = newCore[i].copyWith(onlineCores: onlineCores);
                }

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
      _RateLimitsCard(
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

    sections.add(const SizedBox(height: AppConstants.spacing20));

    // ── GPU ──────────────────────────────────────────────────────────────
    sections.add(_SectionLabel(label: 'GPU', color: profileColor));
    sections.add(const SizedBox(height: AppConstants.spacing8));
    sections.add(
      GpuCard(
        gpuFreq: config.gpu.gpuFreq,
        gpuGovernor: config.gpu.gpuGovernor,
        availableFreqs: device.gpuFreqs,
        availableGovernors: device.gpuGovernors,
        hasGovernor: device.gpuHasGovernor,
        color: profileColor,
        onChanged: (freq, gov) {
          notifier.update(
            config.copyWith(
              gpu: GpuConfig(gpuFreq: freq, gpuGovernor: gov),
            ),
          );
        },
      ),
    );

    sections.add(const SizedBox(height: AppConstants.spacing20));

    // ── DEVFREQ ──────────────────────────────────────────────────────────
    sections.add(_SectionLabel(label: 'DRAM DVFS', color: profileColor));
    sections.add(const SizedBox(height: AppConstants.spacing8));
    sections.add(
      DevfreqCard(
        dvfGovernor: config.devfreq.dvfGovernor,
        availableGovernors: device.dvfGovernors,
        color: profileColor,
        onChanged: (gov) {
          notifier.update(
            config.copyWith(devfreq: DevfreqConfig(dvfGovernor: gov)),
          );
        },
      ),
    );

    sections.add(const SizedBox(height: AppConstants.spacing20));

    // ── UFS ──────────────────────────────────────────────────────────────
    sections.add(_SectionLabel(label: 'UFS', color: profileColor));
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
              ufs: UfsConfig(ufsGovernor: gov, ufsClkEnable: clk),
            ),
          );
        },
      ),
    );

    sections.add(const SizedBox(height: AppConstants.spacing20));

    // ── FPSGO ────────────────────────────────────────────────────────────
    sections.add(_SectionLabel(label: 'FPSGO', color: profileColor));
    sections.add(const SizedBox(height: AppConstants.spacing8));
    sections.add(
      FpsgoCard(
        forceOnOff: config.fpsgo.forceOnOff,
        boostTa: config.fpsgo.boostTa,
        color: profileColor,
        onChanged: (force, boost) {
          notifier.update(
            config.copyWith(
              fpsgo: FpsgoConfig(forceOnOff: force, boostTa: boost),
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

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

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

// ── Rate limits card ──────────────────────────────────────────────────────────

class _RateLimitsCard extends StatelessWidget {
  final List<int> downRateLimitUs;
  final List<int> upRateLimitUs;

  /// CPU policies — used for cluster labels (Little / Mid / Prime).
  final List<CpuPolicy> policies;
  final Color color;
  final void Function(List<int> down, List<int> up) onChanged;

  const _RateLimitsCard({
    required this.downRateLimitUs,
    required this.upRateLimitUs,
    required this.policies,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final count = policies.isNotEmpty ? policies.length : downRateLimitUs.length;

    // Ensure lists are at least `count` long (broadcast last value if needed).
    List<int> pad(List<int> src) {
      if (src.isEmpty) return List.filled(count, 1000);
      if (src.length >= count) return src.take(count).toList();
      return [...src, ...List.filled(count - src.length, src.last)];
    }

    final downs = pad(downRateLimitUs);
    final ups = pad(upRateLimitUs);

    return SectionCard(
      title: 'Rate Limits',
      icon: Icons.timer_outlined,
      color: color,
      initiallyExpanded: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < count; i++) ...[
            // Cluster label chip
            if (i < policies.length)
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spacing8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing8,
                          vertical: AppConstants.spacing4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius:
                            BorderRadius.circular(AppConstants.spacing8),
                        border:
                            Border.all(color: color.withValues(alpha: 0.30)),
                      ),
                      child: Text(
                        policies[i].clusterName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Text(
                      policies[i].cpuLabel,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            // Down / Up fields side by side
            Row(
              children: [
                Expanded(
                  child: _RateField(
                    label: 'DOWN (µs)',
                    hint: '10000',
                    value: downs[i],
                    color: color,
                    onChanged: (v) {
                      final nd = List<int>.from(downs)..[i] = v;
                      onChanged(nd, ups);
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: _RateField(
                    label: 'UP (µs)',
                    hint: '1000',
                    value: ups[i],
                    color: color,
                    onChanged: (v) {
                      final nu = List<int>.from(ups)..[i] = v;
                      onChanged(downs, nu);
                    },
                  ),
                ),
              ],
            ),
            if (i < count - 1)
              const SizedBox(height: AppConstants.spacing16),
          ],
        ],
      ),
    );
  }
}


class _RateField extends StatefulWidget {
  final String label;
  final String hint;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  const _RateField({
    required this.label,
    required this.hint,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  State<_RateField> createState() => _RateFieldState();
}

class _RateFieldState extends State<_RateField> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toString());
    _focus = FocusNode();
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(_RateField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_focus.hasFocus) {
      _ctrl.text = widget.value.toString();
    }
  }

  void _commit() {
    final v = int.tryParse(_ctrl.text);
    if (v != null && v != widget.value) widget.onChanged(v);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextField(
      controller: _ctrl,
      focusNode: _focus,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixText: 'µs',
        filled: true,
        fillColor: widget.color.withValues(alpha: 0.06),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing12,
          vertical: AppConstants.spacing10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: widget.color.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: widget.color.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: BorderSide(color: widget.color, width: 1.5),
        ),
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: cs.onSurfaceVariant,
        ),
      ),
      onSubmitted: (_) => _commit(),
    );
  }
}

// ── Save FAB ──────────────────────────────────────────────────────────────────

class _SaveFab extends ConsumerWidget {
  final ProfileType profile;
  final ProfileEditorState editorState;
  final ProfileConfig savedConfig;
  final Color color;

  const _SaveFab({
    required this.profile,
    required this.editorState,
    required this.savedConfig,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSaving = editorState.isSaving;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Revert button
        FloatingActionButton.small(
          heroTag: 'revert_${profile.value}',
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          foregroundColor: theme.colorScheme.onSurfaceVariant,
          elevation: 4,
          onPressed: isSaving
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(profileEditorProvider(profile).notifier)
                      .revert(savedConfig);
                },
          tooltip: 'Revert changes',
          child: const Icon(Icons.undo_rounded),
        ),
        const SizedBox(width: AppConstants.spacing8),

        // Save button
        FloatingActionButton.extended(
          heroTag: 'save_${profile.value}',
          backgroundColor: isSaving ? color.withValues(alpha: 0.6) : color,
          foregroundColor: Colors.white,
          elevation: isSaving ? 0 : 6,
          onPressed: isSaving
              ? null
              : () async {
                  HapticFeedback.mediumImpact();
                  final ok = await ref
                      .read(profileEditorProvider(profile).notifier)
                      .save();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? AppLocale.configSaved.getString(context)
                              : (editorState.errorMessage ??
                                    AppLocale.configSaveError.getString(
                                      context,
                                    )),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: ok ? null : theme.colorScheme.error,
                      ),
                    );
                  }
                },
          icon: isSaving
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                )
              : const Icon(Icons.save_rounded, size: 20),
          label: Text(
            isSaving
                ? AppLocale.savingConfig.getString(context)
                : AppLocale.saveChanges.getString(context),
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
