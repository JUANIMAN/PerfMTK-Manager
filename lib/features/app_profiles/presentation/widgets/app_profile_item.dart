import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/app_info.dart';
import 'package:manager/features/app_profiles/data/app_profile.dart';
import 'package:manager/features/system/data/models/profile.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/features/app_profiles/presentation/widgets/profile_selection_sheet.dart';
import 'package:manager/features/profiles/presentation/widgets/profile_utils.dart';
import 'package:manager/core/design/design.dart';
import 'package:manager/features/app_profiles/presentation/widgets/app_icon_image.dart';

class AppProfileItem extends StatelessWidget {
  final AppInfo app;
  final ProfileType? currentProfile;
  final AppDirectives? currentDirectives;
  final bool isSystemApp;
  final bool hasHardwareBypass;
  final void Function(ProfileType? profile, AppDirectives? directives)
  onProfileSelected;

  const AppProfileItem({
    super.key,
    required this.app,
    required this.currentProfile,
    this.currentDirectives,
    this.isSystemApp = false,
    this.hasHardwareBypass = false,
    required this.onProfileSelected,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final color = ProfileUtils.colorFor(currentProfile);
    final icon = ProfileUtils.iconFor(currentProfile);
    final isConfigured = currentProfile != null;

    final borderColor = isConfigured
        ? color.withValues(alpha: 0.45)
        : cs.outlineVariant.withValues(alpha: 0.22);
    final bgColor = isConfigured
        ? color.withValues(alpha: 0.05)
        : (isDark
            ? cs.surfaceContainerHigh.withValues(alpha: 0.35)
            : cs.surfaceContainer.withValues(alpha: 0.55));

    // RepaintBoundary isolates each item's repaint from its siblings
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppConstants.spacing8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _showProfileSelectionBottomSheet(context),
            splashColor: isConfigured
                ? color.withValues(alpha: 0.12)
                : cs.primary.withValues(alpha: 0.06),
            highlightColor: isConfigured
                ? color.withValues(alpha: 0.06)
                : cs.primary.withValues(alpha: 0.03),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing14,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: borderColor,
                  width: isConfigured ? 1.2 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  _buildAppIcon(context),
                  const SizedBox(width: AppConstants.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          app.packageName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.65),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppConstants.spacing6),
                        _buildProfileChips(context, color, icon),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isConfigured
                        ? color.withValues(alpha: 0.60)
                        : cs.onSurfaceVariant.withValues(alpha: 0.40),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppIconImage(
              packageName: app.packageName,
              initialIcon: app.icon,
            ),
          ),
        ),
        if (isSystemApp)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.50),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.security_rounded,
                size: 9,
                color: cs.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileChips(BuildContext context, Color color, IconData icon) {
    final isConfigured = currentProfile != null;
    final label = isConfigured
        ? ProfileUtils.nameFor(context, currentProfile!)
        : context.l10n.defaultProfile;

    final profileChip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isConfigured
            ? color.withValues(alpha: 0.15)
            : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isConfigured
              ? color.withValues(alpha: 0.45)
              : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.30),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConfigured ? icon : Icons.tune_rounded,
            size: 11,
            color: isConfigured
                ? color
                : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isConfigured
                  ? color
                  : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
              fontWeight: isConfigured ? FontWeight.w700 : FontWeight.w500,
              fontSize: 10.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    final dirs = currentDirectives;
    final hasExtraChips = dirs != null &&
        (dirs.gbe == 1 ||
            dirs.chargeBypass == true ||
            dirs.disableThermal == true ||
            dirs.fps != null ||
            dirs.touchGameMode == true ||
            dirs.renderBoost == 1 ||
            (dirs.gentleCharge != null && dirs.gentleCharge! > 0));

    if (!hasExtraChips) {
      return profileChip;
    }

    return Wrap(
      spacing: AppConstants.spacing6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        profileChip,
        if (currentDirectives?.gbe == 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: AppPalette.purple.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppPalette.purple.withValues(alpha: 0.50),
                width: 0.9,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sports_esports_rounded,
                  size: 11,
                  color: AppPalette.neonPurple,
                ),
                SizedBox(width: 3.5),
                Text(
                  'GBE',
                  style: TextStyle(
                    color: AppPalette.neonPurple,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        if (currentDirectives?.chargeBypass == true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: AppPalette.neonAmber.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppPalette.neonAmber.withValues(alpha: 0.50),
                width: 0.9,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 12,
                  color: AppPalette.amber,
                ),
                const SizedBox(width: 2.5),
                Text(
                  hasHardwareBypass ? 'HW Bypass' : 'Fast Chg',
                  style: const TextStyle(
                    color: AppPalette.amber,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        if (currentDirectives?.disableThermal == true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: AppPalette.neonRed.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppPalette.neonRed.withValues(alpha: 0.50),
                width: 0.9,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 12,
                  color: AppPalette.neonRed,
                ),
                SizedBox(width: 2.5),
                Text(
                  'Thermal OFF',
                  style: TextStyle(
                    color: AppPalette.neonRed,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        if (currentDirectives?.fps != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: AppPalette.neonGreen.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppPalette.neonGreen.withValues(alpha: 0.50),
                width: 0.9,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.speed_rounded,
                  size: 12,
                  color: AppPalette.neonGreen,
                ),
                const SizedBox(width: 2.5),
                Text(
                  '${currentDirectives!.fps} FPS',
                  style: const TextStyle(
                    color: AppPalette.neonGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        if (currentDirectives?.touchGameMode == true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: AppPalette.neonCyan.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppPalette.neonCyan.withValues(alpha: 0.50),
                width: 0.9,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 12,
                  color: AppPalette.neonCyan,
                ),
                SizedBox(width: 2.5),
                Text(
                  'Touch',
                  style: TextStyle(
                    color: AppPalette.neonCyan,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        if (currentDirectives?.renderBoost == 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: AppPalette.neonOrange.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppPalette.neonOrange.withValues(alpha: 0.50),
                width: 0.9,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.rocket_launch_rounded,
                  size: 11,
                  color: AppPalette.neonOrange,
                ),
                SizedBox(width: 3.5),
                Text(
                  'RenderBoost',
                  style: TextStyle(
                    color: AppPalette.neonOrange,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        if (currentDirectives?.gentleCharge != null &&
            currentDirectives!.gentleCharge! > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: AppPalette.neonTeal.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppPalette.neonTeal.withValues(alpha: 0.50),
                width: 0.9,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.battery_charging_full_rounded,
                  size: 11,
                  color: AppPalette.neonTeal,
                ),
                const SizedBox(width: 3.5),
                Text(
                  'Gentle ${currentDirectives!.gentleCharge}mA',
                  style: const TextStyle(
                    color: AppPalette.neonTeal,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showProfileSelectionBottomSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileSelectionSheet(
        app: app,
        currentProfile: currentProfile,
        currentDirectives: currentDirectives,
        isSystemApp: isSystemApp,
        hasHardwareBypass: hasHardwareBypass,
        onProfileSelected: (profile, directives) {
          onProfileSelected(profile, directives);
        },
      ),
    );
  }
}
