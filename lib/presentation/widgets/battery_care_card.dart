import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';

class BatteryCareCard extends StatefulWidget {
  final bool isEnabled;
  final int limitPct;
  final bool isSuspended;
  final int? currentCapacity;
  final bool isChanging;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onLimitChanged;

  const BatteryCareCard({
    super.key,
    required this.isEnabled,
    required this.limitPct,
    required this.isSuspended,
    this.currentCapacity,
    this.isChanging = false,
    required this.onToggle,
    required this.onLimitChanged,
  });

  @override
  State<BatteryCareCard> createState() => _BatteryCareCardState();
}

class _BatteryCareCardState extends State<BatteryCareCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;

  static const List<int> _presetLimits = [75, 80, 85, 90];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppConstants.animationNormal,
      value: widget.isEnabled ? 1.0 : 0.0,
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(covariant BatteryCareCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final primaryColor = widget.isEnabled
        ? (widget.isSuspended ? const Color(0xFF00E676) : const Color(0xFF00B0FF))
        : cs.onSurfaceVariant;

    return AnimatedBuilder(
      animation: _expandAnim,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            border: Border.all(
              color: widget.isEnabled
                  ? primaryColor.withValues(alpha: 0.35)
                  : cs.outlineVariant.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row ───────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacing12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                    ),
                    child: Icon(
                      widget.isSuspended
                          ? Icons.shield_rounded
                          : Icons.health_and_safety_rounded,
                      color: primaryColor,
                      size: AppConstants.iconSizeLarge,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocale.batteryCareTitle.getString(context),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing4),
                        Text(
                          _getStatusSubtitle(context),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: widget.isSuspended
                                ? const Color(0xFF00E676)
                                : cs.onSurfaceVariant,
                            fontWeight: widget.isSuspended
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  if (widget.isChanging)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    Switch(
                      value: widget.isEnabled,
                      activeThumbColor: primaryColor,
                      onChanged: (val) {
                        HapticFeedback.mediumImpact();
                        widget.onToggle(val);
                      },
                    ),
                ],
              ),

              // ── Description ───────────────────────────────────────────────
              const SizedBox(height: AppConstants.spacing12),
              Text(
                AppLocale.batteryCareDesc.getString(context),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),

              // ── Expandable Slider & Preset Chips ──────────────────────────
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnim.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppConstants.spacing20),
                      const Divider(height: 1),
                      const SizedBox(height: AppConstants.spacing16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocale.batteryCareLimit.getString(context),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${widget.limitPct}%',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing8),

                      // Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: primaryColor,
                          thumbColor: primaryColor,
                          overlayColor: primaryColor.withValues(alpha: 0.2),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: widget.limitPct.toDouble().clamp(70.0, 95.0),
                          min: 70.0,
                          max: 95.0,
                          divisions: 25,
                          onChanged: widget.isEnabled && !widget.isChanging
                              ? (v) {
                                  widget.onLimitChanged(v.round());
                                }
                              : null,
                          onChangeEnd: (v) {
                            HapticFeedback.selectionClick();
                          },
                        ),
                      ),

                      // Preset chips
                      Wrap(
                        spacing: AppConstants.spacing8,
                        children: _presetLimits.map((preset) {
                          final isSelected = widget.limitPct == preset;
                          return ChoiceChip(
                            label: Text(
                              preset == 80
                                  ? '$preset% ★'
                                  : '$preset%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? cs.onPrimary
                                    : cs.onSurface,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: primaryColor,
                            backgroundColor: cs.surfaceContainerHighest,
                            onSelected: widget.isEnabled && !widget.isChanging
                                ? (_) {
                                    HapticFeedback.selectionClick();
                                    widget.onLimitChanged(preset);
                                  }
                                : null,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStatusSubtitle(BuildContext context) {
    if (!widget.isEnabled) {
      return AppLocale.batteryCareNormal.getString(context);
    }
    if (widget.isSuspended) {
      final capStr = widget.currentCapacity != null
          ? ' (${widget.currentCapacity}%)'
          : '';
      return '${AppLocale.batteryCareSuspended.getString(context)}$capStr';
    }
    return '${AppLocale.batteryCareLimit.getString(context)}: ${widget.limitPct}%';
  }
}
