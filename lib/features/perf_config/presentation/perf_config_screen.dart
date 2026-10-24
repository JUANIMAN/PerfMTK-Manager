import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/features/system/data/models/profile.dart';
import 'package:manager/features/perf_config/presentation/widgets/profile_tab_bar.dart';
import 'package:manager/features/perf_config/presentation/widgets/profile_tab_body.dart';

/// Screen for fine-tuning hardware parameters (CPU, GPU, DRAM, UFS, FPSGO, GBE, Thermal) per profile.
class PerfConfigScreen extends ConsumerStatefulWidget {
  const PerfConfigScreen({super.key});

  @override
  ConsumerState<PerfConfigScreen> createState() => _PerfConfigScreenState();
}

class _PerfConfigScreenState extends ConsumerState<PerfConfigScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ProfileType.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppConstants.spacing12),
            // ── Tab bar ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing16,
              ),
              child: ProfileTabBar(controller: _tabController),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.18),
            ),

            // ── Tab views ──────────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: ProfileType.values
                    .map((p) => ProfileTabBody(profile: p))
                    .toList(),
              ),
            ),
          ],
        ),
    );
  }
}
