import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:installed_apps/app_info.dart';
import 'package:manager/data/models/app_profile.dart';
import 'package:manager/data/models/profile.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/presentation/widgets/app_profile_item.dart';
import 'package:manager/presentation/widgets/profile_utils.dart';

class ProfileSelectionSheet extends StatefulWidget {
  final AppInfo app;
  final ProfileType? currentProfile;
  final AppDirectives? currentDirectives;
  final bool isSystemApp;
  final void Function(ProfileType? profile, AppDirectives? directives)
  onProfileSelected;

  const ProfileSelectionSheet({
    super.key,
    required this.app,
    required this.currentProfile,
    this.currentDirectives,
    this.isSystemApp = false,
    required this.onProfileSelected,
  });

  @override
  State<ProfileSelectionSheet> createState() => _ProfileSelectionSheetState();
}

class _ProfileSelectionSheetState extends State<ProfileSelectionSheet> {
  late ProfileType? _selectedProfile;
  late bool _gbe;
  late bool _chargeBypass;
  late bool _disableThermal;
  late bool _touchGameMode;
  late int? _selectedFps;

  @override
  void initState() {
    super.initState();
    _selectedProfile = widget.currentProfile;
    _gbe = widget.currentDirectives?.gbe == 1;
    _chargeBypass = widget.currentDirectives?.chargeBypass == true;
    _disableThermal = widget.currentDirectives?.disableThermal == true;
    _touchGameMode = widget.currentDirectives?.touchGameMode == true;
    _selectedFps = widget.currentDirectives?.fps;
  }

  void _apply(ProfileType? profile) {
    if (profile == null) {
      widget.onProfileSelected(null, null);
      return;
    }
    final directives = AppDirectives(
      gbe: _gbe ? 1 : null,
      chargeBypass: _chargeBypass ? true : null,
      disableThermal: _disableThermal ? true : null,
      touchGameMode: _touchGameMode ? true : null,
      dramMin: widget.currentDirectives?.dramMin,
      uclampMax: widget.currentDirectives?.uclampMax,
      gentleCharge: widget.currentDirectives?.gentleCharge,
      renderBoost: widget.currentDirectives?.renderBoost,
      fps: _selectedFps,
    );
    widget.onProfileSelected(profile, directives.isEmpty ? null : directives);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final profiles = _buildProfiles(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161618) : cs.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : cs.outlineVariant.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // App info header with real app icon
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isDark
                                ? cs.surfaceContainerHigh
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: cs.outlineVariant.withValues(
                                alpha: isDark ? 0.25 : 0.40,
                              ),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.30 : 0.08,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Center(
                            child: AppIconImage(
                              packageName: widget.app.packageName,
                              initialIcon: widget.app.icon,
                              size: 46,
                            ),
                          ),
                        ),
                        if (widget.isSystemApp)
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: cs.primary.withValues(alpha: 0.5),
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                Icons.security_rounded,
                                size: 11,
                                color: cs.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.app.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 16.5,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.app.packageName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.70),
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (widget.isSystemApp)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          AppLocale.systemAppTag.getString(context),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: isDark ? 0.20 : 0.35),
              ),
              const SizedBox(height: 10),

              // Profile options (Modern Squircle Cards)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final p = profiles[index];
                  final isSelected = _selectedProfile == p.profileType;
                  return _AnimatedSheetItem(
                    index: index,
                    child: _buildProfileCard(
                      context: context,
                      profileType: p.profileType,
                      name: p.name,
                      description: p.description,
                      isSelected: isSelected,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedProfile = p.profileType);
                        _apply(p.profileType);
                        if (p.profileType == null) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  );
                },
              ),

              // Directives section (when a profile is assigned)
              if (_selectedProfile != null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? cs.surfaceContainerHigh.withValues(alpha: 0.40)
                          : cs.surfaceContainer.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(
                          alpha: isDark ? 0.25 : 0.35,
                        ),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 14,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocale.gameDirectives.getString(context).toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildDirectiveRow(
                          context: context,
                          icon: Icons.sports_esports_rounded,
                          iconColor: const Color(0xFFE040FB),
                          title: AppLocale.gbeTitle.getString(context),
                          subtitle: AppLocale.gbeDirectiveSubtitle.getString(context),
                          value: _gbe,
                          onChanged: (v) {
                            setState(() => _gbe = v);
                            _apply(_selectedProfile);
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildDirectiveRow(
                          context: context,
                          icon: Icons.bolt_rounded,
                          iconColor: const Color(0xFFFFB300),
                          title: AppLocale.chargeBypassTitle.getString(context),
                          subtitle: AppLocale.bypassDirectiveSubtitle.getString(context),
                          value: _chargeBypass,
                          onChanged: (v) {
                            setState(() => _chargeBypass = v);
                            _apply(_selectedProfile);
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildDirectiveRow(
                          context: context,
                          icon: Icons.local_fire_department_rounded,
                          iconColor: const Color(0xFFFF5252),
                          title: AppLocale.thermalBypassTitle.getString(context),
                          subtitle: AppLocale.thermalBypassSubtitle.getString(context),
                          value: _disableThermal,
                          onChanged: (v) {
                            setState(() => _disableThermal = v);
                            _apply(_selectedProfile);
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildDirectiveRow(
                          context: context,
                          icon: Icons.touch_app_rounded,
                          iconColor: const Color(0xFF00E5FF),
                          title: AppLocale.touchBoosterTitle.getString(context),
                          subtitle: AppLocale.touchBoosterSubtitle.getString(context),
                          value: _touchGameMode,
                          onChanged: (v) {
                            setState(() => _touchGameMode = v);
                            _apply(_selectedProfile);
                          },
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          height: 1,
                          color: cs.outlineVariant.withValues(alpha: isDark ? 0.20 : 0.35),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.speed_rounded,
                              size: 14,
                              color: Color(0xFF00E676),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocale.fpsgoHeader.getString(context),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildFpsChip(context, label: 'Auto', value: null, isDark: isDark),
                            const SizedBox(width: 8),
                            _buildFpsChip(context, label: '60 FPS', value: 60, isDark: isDark),
                            const SizedBox(width: 8),
                            _buildFpsChip(context, label: '90 FPS', value: 90, isDark: isDark),
                            const SizedBox(width: 8),
                            _buildFpsChip(context, label: '120 FPS', value: 120, isDark: isDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required BuildContext context,
    required ProfileType? profileType,
    required String name,
    required String description,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final color = ProfileUtils.colorFor(profileType, isDark: isDark);
    final icon = ProfileUtils.iconFor(profileType);

    final cardBg = isSelected
        ? color.withValues(alpha: isDark ? 0.14 : 0.09)
        : (isDark
            ? cs.surfaceContainerHigh.withValues(alpha: 0.35)
            : cs.surfaceContainer.withValues(alpha: 0.45));
    final cardBorder = isSelected
        ? color.withValues(alpha: isDark ? 0.55 : 0.45)
        : cs.outlineVariant.withValues(alpha: isDark ? 0.20 : 0.30);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3.5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withValues(alpha: 0.12),
          highlightColor: color.withValues(alpha: 0.06),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cardBorder,
                width: isSelected ? 1.4 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isSelected ? 0.20 : 0.12),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: color.withValues(alpha: isSelected ? 0.45 : 0.25),
                      width: 0.9,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? (isDark ? Colors.white : color)
                              : cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.80),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? color : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? color
                          : cs.outlineVariant.withValues(alpha: 0.60),
                      width: isSelected ? 1.5 : 1.2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectiveRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.35),
              width: 0.8,
            ),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.85,
          child: Switch(
            value: value,
            activeThumbColor: iconColor,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFpsChip(
    BuildContext context, {
    required String label,
    required int? value,
    required bool isDark,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _selectedFps == value;
    const accentColor = Color(0xFF00E676);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedFps = value);
            _apply(_selectedProfile);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(alpha: isDark ? 0.20 : 0.14)
                  : (isDark
                      ? cs.surfaceContainerHighest.withValues(alpha: 0.35)
                      : cs.surfaceContainerHighest.withValues(alpha: 0.45)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.65)
                    : cs.outlineVariant.withValues(alpha: 0.25),
                width: isSelected ? 1.2 : 0.8,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? accentColor : const Color(0xFF00A352))
                      : cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<_SheetProfileData> _buildProfiles(BuildContext context) {
    return [
      _SheetProfileData(
        profileType: null,
        name: AppLocale.defaultProfile.getString(context),
        description: AppLocale.defaultProfileDesc.getString(context),
      ),
      _SheetProfileData(
        profileType: ProfileType.performance,
        name: ProfileUtils.nameFor(context, ProfileType.performance),
        description: AppLocale.performanceDesc.getString(context),
      ),
      _SheetProfileData(
        profileType: ProfileType.balanced,
        name: ProfileUtils.nameFor(context, ProfileType.balanced),
        description: AppLocale.balancedDesc.getString(context),
      ),
      _SheetProfileData(
        profileType: ProfileType.powersave,
        name: ProfileUtils.nameFor(context, ProfileType.powersave),
        description: AppLocale.powersaveDesc.getString(context),
      ),
      _SheetProfileData(
        profileType: ProfileType.powersavePlus,
        name: ProfileUtils.nameFor(context, ProfileType.powersavePlus),
        description: AppLocale.powersavePlusDesc.getString(context),
      ),
    ];
  }
}

class _SheetProfileData {
  final ProfileType? profileType;
  final String name;
  final String description;
  const _SheetProfileData({
    required this.profileType,
    required this.name,
    required this.description,
  });
}

// ── Animated slide-in for each sheet item ─────────────────────────────────────
class _AnimatedSheetItem extends StatefulWidget {
  final Widget child;
  final int index;
  const _AnimatedSheetItem({required this.child, required this.index});
  @override
  State<_AnimatedSheetItem> createState() => _AnimatedSheetItemState();
}

class _AnimatedSheetItemState extends State<_AnimatedSheetItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppConstants.animationNormal,
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.12, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 35 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
