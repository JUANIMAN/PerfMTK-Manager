import 'package:flutter/material.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/presentation/widgets/profile_utils.dart';

/// Tab bar for selecting hardware configuration profiles (Perf, Balanced, Save, Save+).
class ProfileTabBar extends StatelessWidget {
  final TabController controller;
  const ProfileTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHigh.withValues(alpha: 0.45)
            : cs.surfaceContainer.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : cs.outlineVariant.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: controller,
        isScrollable: false,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 2),
        indicator: const BoxDecoration(),
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        tabs: ProfileType.values.map((p) {
          final color = ProfileUtils.colorFor(p, isDark: isDark);
          final icon = ProfileUtils.iconFor(p);
          return Tab(
            height: 40,
            child: TabChip(
              icon: icon,
              label: ProfileUtils.shortNameFor(context, p),
              color: color,
              controller: controller,
              index: ProfileType.values.indexOf(p),
              isDark: isDark,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TabChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final TabController controller;
  final int index;
  final bool isDark;

  const TabChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.controller,
    required this.index,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final unselectedColor = isDark
        ? cs.onSurfaceVariant.withValues(alpha: 0.65)
        : const Color(0xFF475569);

    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final selected = controller.index == index;
        return AnimatedContainer(
          duration: AppConstants.animationFast,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: isDark ? 0.18 : 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(
                    color: color.withValues(alpha: isDark ? 0.55 : 0.65),
                    width: 1.1,
                  )
                : Border.all(color: Colors.transparent, width: 1.1),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: isDark ? 0.22 : 0.15),
                      blurRadius: 8,
                      spreadRadius: 0.5,
                    ),
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: selected ? color : unselectedColor,
                ),
                const SizedBox(width: 4.5),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected ? color : unselectedColor,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
