import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:installed_apps/app_info.dart';
import 'package:manager/core/utils/app_icon_cache.dart';
import 'package:manager/data/models/app_profile.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/widgets/profile_selection_sheet.dart';
import 'package:manager/presentation/widgets/profile_utils.dart';
import 'package:manager/config/app_constants.dart';

class AppProfileItem extends StatelessWidget {
  final AppInfo app;
  final ProfileType? currentProfile;
  final AppDirectives? currentDirectives;
  final bool isSystemApp;
  final void Function(ProfileType? profile, AppDirectives? directives)
  onProfileSelected;

  const AppProfileItem({
    super.key,
    required this.app,
    required this.currentProfile,
    this.currentDirectives,
    this.isSystemApp = false,
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
                boxShadow: isConfigured
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
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
        : AppLocale.defaultProfile.getString(context);

    return Wrap(
      spacing: AppConstants.spacing6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
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
        ),
        if (currentDirectives?.gbe == 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFFD500F9).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFD500F9).withValues(alpha: 0.50),
                width: 0.9,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sports_esports_rounded,
                  size: 11,
                  color: Color(0xFFE040FB),
                ),
                SizedBox(width: 3.5),
                Text(
                  'GBE',
                  style: TextStyle(
                    color: Color(0xFFE040FB),
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
              color: const Color(0xFFFFB300).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFFFB300).withValues(alpha: 0.50),
                width: 0.9,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: 12,
                  color: Color(0xFFFFC107),
                ),
                SizedBox(width: 2.5),
                Text(
                  'Bypass',
                  style: TextStyle(
                    color: Color(0xFFFFC107),
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
              color: const Color(0xFFFF5252).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFFF5252).withValues(alpha: 0.50),
                width: 0.9,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 12,
                  color: Color(0xFFFF5252),
                ),
                SizedBox(width: 2.5),
                Text(
                  'Thermal OFF',
                  style: TextStyle(
                    color: Color(0xFFFF5252),
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
              color: const Color(0xFF00E676).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF00E676).withValues(alpha: 0.50),
                width: 0.9,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.speed_rounded,
                  size: 12,
                  color: Color(0xFF00E676),
                ),
                const SizedBox(width: 2.5),
                Text(
                  '${currentDirectives!.fps} FPS',
                  style: const TextStyle(
                    color: Color(0xFF00E676),
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
              color: const Color(0xFF00E5FF).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.50),
                width: 0.9,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 12,
                  color: Color(0xFF00E5FF),
                ),
                SizedBox(width: 2.5),
                Text(
                  'Touch',
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
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
        onProfileSelected: (profile, directives) {
          Navigator.of(context).pop();
          onProfileSelected(profile, directives);
        },
      ),
    );
  }
}

/// Renders an app icon either from memory, cache, or lazily on demand.
class AppIconImage extends StatefulWidget {
  final String packageName;
  final Uint8List? initialIcon;
  final double size;

  const AppIconImage({
    super.key,
    required this.packageName,
    this.initialIcon,
    this.size = 44,
  });

  @override
  State<AppIconImage> createState() => _AppIconImageState();
}

class _AppIconImageState extends State<AppIconImage> {
  Uint8List? _iconBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _resolveIcon();
  }

  @override
  void didUpdateWidget(AppIconImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) {
      _resolveIcon();
    }
  }

  void _resolveIcon() {
    _iconBytes =
        widget.initialIcon ??
        AppIconCache.instance.getCached(widget.packageName);
    if (_iconBytes == null && !_isLoading) {
      _isLoading = true;
      AppIconCache.instance.loadIcon(widget.packageName).then((bytes) {
        if (mounted) {
          setState(() {
            _iconBytes = bytes;
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _iconBytes;
    if (icon != null) {
      return Image.memory(
        icon,
        width: widget.size,
        height: widget.size,
        cacheWidth: 96,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Icon(Icons.android_rounded, size: widget.size * 0.65),
    );
  }
}
