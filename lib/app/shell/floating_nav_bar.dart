import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/app/shell/nav_tab.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/l10n/l10n.dart';

/// Frosted, floating bottom navigation bar. The selected item expands to show
/// its label.
class FloatingNavBar extends ConsumerWidget {
  const FloatingNavBar({super.key});

  static const double _height = 62;
  static const double _radius = AppConstants.radiusXXLarge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.perfColors;
    final isDark = context.isDarkMode;
    final tabs = ref.watch(visibleNavTabsProvider);
    final selected = ref.watch(effectiveNavTabProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacing16,
          0,
          AppConstants.spacing16,
          AppConstants.spacing10,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: _height,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.glassFill,
                borderRadius: BorderRadius.circular(_radius),
                border: Border.all(color: colors.glassBorder),
                boxShadow: _shadows(isDark),
              ),
              child: Row(
                children: [
                  for (final tab in tabs)
                    Expanded(
                      flex: tab == selected ? 16 : 9,
                      child: _NavItem(
                        tab: tab,
                        isSelected: tab == selected,
                        onTap: () {
                          if (tab == selected) return;
                          HapticFeedback.lightImpact();
                          ref.read(selectedNavTabProvider.notifier).select(tab);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static List<BoxShadow> _shadows(bool isDark) => isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ];
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final NavTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.perfColors;
    final isDark = context.isDarkMode;
    final accent = colors.accent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Center(
        child: AnimatedContainer(
          duration: AppConstants.animationFast + const Duration(milliseconds: 50),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 14 : 12,
            vertical: 8,
          ),
          decoration: isSelected
              ? BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.16 : 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: accent.withValues(alpha: isDark ? 0.40 : 0.35),
                  ),
                  boxShadow: [
                    isDark
                        ? BoxShadow(
                            color: accent.withValues(alpha: 0.22),
                            blurRadius: 10,
                            spreadRadius: 0.5,
                          )
                        : BoxShadow(
                            color: accent.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                  ],
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? tab.selectedIcon : tab.unselectedIcon,
                color: isSelected ? accent : colors.navIdle,
                size: isSelected ? 20 : 21,
              ),
              if (isSelected) ...[
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    tab.label(context.l10n),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accent,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
