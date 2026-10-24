import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/core/design/app_constants.dart';
import 'package:manager/l10n/l10n.dart';

class ChargeSpeedCard extends StatefulWidget {
  final int currentLimitMa;
  final int? liveCurrentMa;
  final bool isChanging;
  final ValueChanged<int> onLimitChanged;

  const ChargeSpeedCard({
    super.key,
    required this.currentLimitMa,
    this.liveCurrentMa,
    this.isChanging = false,
    required this.onLimitChanged,
  });

  @override
  State<ChargeSpeedCard> createState() => _ChargeSpeedCardState();
}

class _ChargeSpeedCardState extends State<ChargeSpeedCard> {
  late int _activeLimitMa;
  late double _sliderVal;

  @override
  void initState() {
    super.initState();
    _activeLimitMa = widget.currentLimitMa;
    _sliderVal = widget.currentLimitMa > 0
        ? widget.currentLimitMa.toDouble().clamp(500.0, 6000.0)
        : 6000.0;
  }

  @override
  void didUpdateWidget(covariant ChargeSpeedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLimitMa != oldWidget.currentLimitMa) {
      setState(() {
        _activeLimitMa = widget.currentLimitMa;
        _sliderVal = widget.currentLimitMa > 0
            ? widget.currentLimitMa.toDouble().clamp(500.0, 6000.0)
            : 6000.0;
      });
    }
  }

  void _applyLimit(int ma) {
    HapticFeedback.selectionClick();
    setState(() {
      _activeLimitMa = ma;
      _sliderVal = ma > 0 ? ma.toDouble() : 6000.0;
    });
    widget.onLimitChanged(ma);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const speedColor = Color(0xFF00E5FF); // Electric cyan

    final isUnlimited = _activeLimitMa <= 0;
    final isCustom = !const [0, 3000, 2000, 1000].contains(_activeLimitMa);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(
          color: !isUnlimited
              ? speedColor.withValues(alpha: 0.35)
              : cs.outlineVariant.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ─────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing12),
                decoration: BoxDecoration(
                  color: speedColor.withValues(alpha: isDark ? 0.15 : 0.10),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  border: Border.all(
                    color: speedColor.withValues(alpha: isDark ? 0.35 : 0.25),
                    width: 0.8,
                  ),
                ),
                child: widget.isChanging
                    ? const SizedBox(
                        width: AppConstants.iconSizeLarge,
                        height: AppConstants.iconSizeLarge,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(speedColor),
                        ),
                      )
                    : const Icon(
                        Icons.bolt_rounded,
                        color: speedColor,
                        size: AppConstants.iconSizeLarge,
                      ),
              ),
              const SizedBox(width: AppConstants.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          context.l10n.chargeSpeedRegulator,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.isChanging) ...[
                          const SizedBox(width: AppConstants.spacing8),
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              valueColor: AlwaysStoppedAnimation(speedColor),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      context.l10n.chargeSpeedDesc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing16),

          // ── Active Limit Telemetry Pill ────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing12,
              vertical: AppConstants.spacing8,
            ),
            decoration: BoxDecoration(
              color: isUnlimited
                  ? cs.surfaceContainerHighest.withValues(alpha: 0.50)
                  : speedColor.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(
                color: isUnlimited
                    ? cs.outlineVariant.withValues(alpha: 0.30)
                    : speedColor.withValues(alpha: 0.30),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isUnlimited
                          ? Icons.flash_on_rounded
                          : Icons.tune_rounded,
                      size: 16,
                      color: isUnlimited ? cs.onSurfaceVariant : speedColor,
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                    Text(
                      isUnlimited
                          ? context.l10n.unlimitedTurbo
                          : '$_activeLimitMa mA  (~${(_activeLimitMa * 4.0 / 1000).toStringAsFixed(1)}W)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isUnlimited ? cs.onSurface : speedColor,
                      ),
                    ),
                  ],
                ),
                if (widget.liveCurrentMa != null && widget.liveCurrentMa! > 0)
                  Text(
                    'Live: ${widget.liveCurrentMa} mA',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacing16),

          // ── 2x2 Tactile Preset Buttons ──────────────────────────────
          Row(
            children: [
              Expanded(
                child: _PresetTile(
                  title: 'Turbo / Máx',
                  subtitle: '67W Ilimitada',
                  icon: Icons.flash_on_rounded,
                  isSelected: _activeLimitMa <= 0,
                  accentColor: speedColor,
                  onTap: () => _applyLimit(0),
                ),
              ),
              const SizedBox(width: AppConstants.spacing10),
              Expanded(
                child: _PresetTile(
                  title: 'Rápida',
                  subtitle: '3000 mA · ~12W',
                  icon: Icons.bolt_rounded,
                  isSelected: _activeLimitMa == 3000,
                  accentColor: speedColor,
                  onTap: () => _applyLimit(3000),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing10),
          Row(
            children: [
              Expanded(
                child: _PresetTile(
                  title: 'Equilibrada',
                  subtitle: '2000 mA · ~8W',
                  icon: Icons.battery_charging_full_rounded,
                  isSelected: _activeLimitMa == 2000,
                  accentColor: speedColor,
                  onTap: () => _applyLimit(2000),
                ),
              ),
              const SizedBox(width: AppConstants.spacing10),
              Expanded(
                child: _PresetTile(
                  title: 'Nocturna',
                  subtitle: '1000 mA · ~4W',
                  icon: Icons.nightlight_round,
                  isSelected: _activeLimitMa == 1000,
                  accentColor: speedColor,
                  onTap: () => _applyLimit(1000),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing20),

          // ── Custom Continuous Slider ────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.customLimit,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_sliderVal.round()} mA  (~${(_sliderVal * 4.0 / 1000).toStringAsFixed(1)}W)',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isCustom ? speedColor : cs.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: speedColor,
                  thumbColor: speedColor,
                  overlayColor: speedColor.withValues(alpha: 0.20),
                  inactiveTrackColor: cs.outlineVariant.withValues(alpha: 0.25),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _sliderVal,
                  min: 500,
                  max: 6000,
                  divisions: 55, // 100 mA steps from 500 to 6000
                  onChanged: (val) {
                    final rounded = val.round();
                    if ((rounded % 500 == 0) && rounded != _sliderVal.round()) {
                      HapticFeedback.selectionClick();
                    }
                    setState(() {
                      _sliderVal = val;
                      _activeLimitMa = rounded;
                    });
                  },
                  onChangeEnd: (val) {
                    _applyLimit(val.round());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tactile Preset Button Card with immediate visual feedback
class _PresetTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _PresetTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing12,
            vertical: AppConstants.spacing10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: isDark ? 0.20 : 0.14)
                : cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.35 : 0.45),
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.65)
                  : cs.outlineVariant.withValues(alpha: 0.20),
              width: isSelected ? 1.4 : 0.8,
            ),
            boxShadow: isSelected && isDark
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor
                      : accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? (isDark ? Colors.black : Colors.white)
                      : accentColor,
                ),
              ),
              const SizedBox(width: AppConstants.spacing10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? accentColor : cs.onSurface,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
