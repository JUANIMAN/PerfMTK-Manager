import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manager/app/routes.dart';
import 'package:manager/app/shell/nav_tab.dart';
import 'package:manager/core/app_info.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/features/system/presentation/system_provider.dart';
import 'package:manager/l10n/l10n.dart';

/// Title, foreground-engine badge and shortcuts (backups, settings).
class AppTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, required this.tab});

  final NavTab tab;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fgEngine = ref.watch(
      systemStateProvider.select((s) => s.value?.fgEngine ?? ''),
    );

    return AppBar(
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: Text(
          switch (tab) {
            NavTab.profiles => AppInfo.name,
            NavTab.battery => l.titleBattery,
            NavTab.appProfiles => l.appProfiles,
            NavTab.perfConfig => l.perfConfig,
          },
          key: ValueKey(tab),
        ),
      ),
      actions: [
        if (fgEngine.isNotEmpty) _EngineBadge(fgEngine: fgEngine),
        if (tab == NavTab.perfConfig)
          IconButton(
            icon: const Icon(Icons.backup_rounded),
            tooltip: l.backupManager,
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push(AppRoutes.backup);
            },
          ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          tooltip: l.settings,
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push(AppRoutes.settings);
          },
        ),
        const SizedBox(width: AppConstants.spacing4),
      ],
    );
  }
}

class _EngineBadge extends StatelessWidget {
  const _EngineBadge({required this.fgEngine});

  final String fgEngine;

  static String _label(String engine) {
    final e = engine.toLowerCase();
    if (e.contains('lsposed')) return 'LSPosed';
    if (e.contains('cgroup')) return 'cgroup';
    return 'Poller';
  }

  @override
  Widget build(BuildContext context) {
    final color = context.perfColors.engine;
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.35 : 0.40),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 4),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _label(fgEngine),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
