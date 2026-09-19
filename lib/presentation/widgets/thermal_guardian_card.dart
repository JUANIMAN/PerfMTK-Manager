import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/app_constants.dart';
import 'package:manager/localization/app_locales.dart';

class ThermalGuardianCard extends StatefulWidget {
  final bool isEnabled;
  final String status;
  final int targetTempC;
  final int currentClampStep;
  final int maxSteps;
  final double trend;
  final double? currentSocTempC;
  final bool isChanging;
  final ValueChanged<bool> onToggle;
  final void Function(int targetTempC, int maxSteps) onSettingsChanged;

  const ThermalGuardianCard({
    super.key,
    required this.isEnabled,
    required this.status,
    required this.targetTempC,
    required this.currentClampStep,
    required this.maxSteps,
    required this.trend,
    this.currentSocTempC,
    this.isChanging = false,
    required this.onToggle,
    required this.onSettingsChanged,
  });

  @override
  State<ThermalGuardianCard> createState() => _ThermalGuardianCardState();
}

class _ThermalGuardianCardState extends State<ThermalGuardianCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;

  late double _currentTempSlider;
  late int _selectedMaxSteps;

  @override
  void initState() {
    super.initState();
    _currentTempSlider = widget.targetTempC.toDouble().clamp(65.0, 85.0);
    _selectedMaxSteps = widget.maxSteps.clamp(1, 3);

    _ctrl = AnimationController(
      vsync: this,
      duration: AppConstants.animationNormal,
      value: widget.isEnabled ? 1.0 : 0.0,
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(covariant ThermalGuardianCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
    if (widget.targetTempC != oldWidget.targetTempC) {
      _currentTempSlider = widget.targetTempC.toDouble().clamp(65.0, 85.0);
    }
    if (widget.maxSteps != oldWidget.maxSteps) {
      _selectedMaxSteps = widget.maxSteps.clamp(1, 3);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _getStatusColor(ColorScheme cs) {
    if (!widget.isEnabled) return cs.onSurfaceVariant;
    if (widget.status.contains('clamping')) return const Color(0xFFFF5252);
    if (widget.status.contains('cooldown')) return const Color(0xFF00E5FF);
    if (widget.status.contains('monitoring')) return const Color(0xFFFFD740);
    return const Color(0xFF00E676);
  }

  String _getStatusLabel(BuildContext context) {
    if (!widget.isEnabled) return AppLocale.tgStatusDisabled.getString(context);
    if (widget.status.contains('clamping')) {
      return AppLocale.tgStatusClamping
          .getString(context)
          .replaceAll('{step}', widget.currentClampStep.toString())
          .replaceAll('{max}', widget.maxSteps.toString());
    }
    if (widget.status.contains('cooldown')) {
      return AppLocale.tgStatusCooldown.getString(context);
    }
    if (widget.status.contains('monitoring')) {
      return AppLocale.tgStatusMonitoring.getString(context);
    }
    return AppLocale.tgStatusNominal.getString(context);
  }

  String _getSubtitleStatus(BuildContext context) {
    if (!widget.isEnabled) return AppLocale.tgSubDisabled.getString(context);
    if (widget.status.contains('clamping')) {
      return AppLocale.tgSubClamping
          .getString(context)
          .replaceAll('{pct}', (widget.currentClampStep * 12).toString());
    }
    if (widget.status.contains('cooldown')) {
      return AppLocale.tgSubCooldown.getString(context);
    }
    if (widget.status.contains('monitoring')) {
      return AppLocale.tgSubMonitoring.getString(context);
    }
    return AppLocale.tgSubNominal.getString(context);
  }

  IconData _getStatusIcon() {
    if (!widget.isEnabled) return Icons.shield_outlined;
    if (widget.status.contains('clamping')) return Icons.warning_amber_rounded;
    if (widget.status.contains('cooldown')) return Icons.ac_unit_rounded;
    if (widget.status.contains('monitoring')) return Icons.speed_rounded;
    return Icons.verified_user_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = _getStatusColor(cs);

    return AnimatedBuilder(
      animation: _expandAnim,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            border: Border.all(
              color: widget.isEnabled
                  ? primaryColor.withValues(alpha: 0.4)
                  : cs.outlineVariant.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row (Icon + Titles + Switch) ────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacing12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(
                        alpha: widget.isEnabled ? 0.15 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusLarge,
                      ),
                      border: Border.all(
                        color: primaryColor.withValues(
                          alpha: widget.isEnabled ? 0.35 : 0.15,
                        ),
                      ),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              'Thermal Guardian',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (widget.isEnabled ? primaryColor : cs.primary)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: (widget.isEnabled ? primaryColor : cs.primary)
                                      .withValues(alpha: 0.3),
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                AppLocale.tgPredictive.getString(context),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: widget.isEnabled ? primaryColor : cs.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _getSubtitleStatus(context),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: widget.isEnabled
                                ? primaryColor.withValues(alpha: 0.9)
                                : cs.onSurfaceVariant,
                            fontWeight: widget.isEnabled
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  Switch(
                    value: widget.isEnabled,
                    activeThumbColor: primaryColor,
                    onChanged: widget.isChanging
                        ? null
                        : (val) {
                            HapticFeedback.lightImpact();
                            widget.onToggle(val);
                          },
                  ),
                ],
              ),

              // ── Full-Width Description ────────────────────────────────────
              const SizedBox(height: AppConstants.spacing12),
              Text(
                AppLocale.tgDescription.getString(context),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.35,
                ),
              ),

              // ── Expandable Configuration & Realtime HUD ──────────────────
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnim.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppConstants.spacing16),
                      const Divider(height: 1),
                      const SizedBox(height: AppConstants.spacing16),

                      // Live Status & Trend HUD Row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacing14,
                          vertical: AppConstants.spacing12,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLowest.withValues(
                            alpha: isDark ? 0.6 : 0.8,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium,
                          ),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocale.tgRealtimeStatus.getString(context),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 10,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getStatusLabel(context),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 32,
                              width: 1,
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spacing12,
                              ),
                              color: cs.outlineVariant.withValues(alpha: 0.3),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  AppLocale.tgTrend.getString(context),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.trend > 0.05
                                          ? Icons.trending_up_rounded
                                          : (widget.trend < -0.05
                                              ? Icons.trending_down_rounded
                                              : Icons.trending_flat_rounded),
                                      size: 16,
                                      color: widget.trend > 0.35
                                          ? const Color(0xFFFF5252)
                                          : (widget.trend > 0.1
                                              ? const Color(0xFFFFD740)
                                              : const Color(0xFF00E676)),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.trend >= 0 ? '+' : ''}${widget.trend.toStringAsFixed(2)}°C/s',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: widget.trend > 0.35
                                            ? const Color(0xFFFF5252)
                                            : (widget.trend > 0.1
                                                ? const Color(0xFFFFD740)
                                                : const Color(0xFF00E676)),
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spacing20),

                      // Target Temp Slider Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocale.tgTargetTemp.getString(context),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusMedium,
                              ),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.35),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '${_currentTempSlider.toInt()}°C',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: primaryColor,
                          thumbColor: primaryColor,
                          overlayColor: primaryColor.withValues(alpha: 0.2),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: _currentTempSlider,
                          min: 65.0,
                          max: 85.0,
                          divisions: 20,
                          onChanged: widget.isEnabled && !widget.isChanging
                              ? (val) {
                                  setState(() {
                                    _currentTempSlider = val;
                                  });
                                }
                              : null,
                          onChangeEnd: (val) {
                            HapticFeedback.selectionClick();
                            widget.onSettingsChanged(
                              val.toInt(),
                              _selectedMaxSteps,
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocale.tgTempCool.getString(context),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              AppLocale.tgTempRecommended.getString(context),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: primaryColor.withValues(alpha: 0.9),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              AppLocale.tgTempExtreme.getString(context),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spacing20),

                      // Max Steps Selector (Full-Width Segmented Cards)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocale.tgClampingAggressiveness.getString(context),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _selectedMaxSteps == 1
                                ? AppLocale.tgStepSummary1.getString(context)
                                : (_selectedMaxSteps == 2
                                    ? AppLocale.tgStepSummary2.getString(context)
                                    : AppLocale.tgStepSummary3.getString(context)),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing10),

                      Row(
                        children: [
                          _buildStepOption(
                            context: context,
                            steps: 1,
                            title: AppLocale.tgStep1Title.getString(context),
                            subtitle: AppLocale.tgStep1Subtitle.getString(context),
                            isDark: isDark,
                            cs: cs,
                            primaryColor: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          _buildStepOption(
                            context: context,
                            steps: 2,
                            title: AppLocale.tgStep2Title.getString(context),
                            subtitle: AppLocale.tgStep2Subtitle.getString(context),
                            isDark: isDark,
                            cs: cs,
                            primaryColor: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          _buildStepOption(
                            context: context,
                            steps: 3,
                            title: AppLocale.tgStep3Title.getString(context),
                            subtitle: AppLocale.tgStep3Subtitle.getString(context),
                            isDark: isDark,
                            cs: cs,
                            primaryColor: primaryColor,
                          ),
                        ],
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

  Widget _buildStepOption({
    required BuildContext context,
    required int steps,
    required String title,
    required String subtitle,
    required bool isDark,
    required ColorScheme cs,
    required Color primaryColor,
  }) {
    final isSelected = _selectedMaxSteps == steps;
    final theme = Theme.of(context);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isEnabled && !widget.isChanging
              ? () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedMaxSteps = steps;
                  });
                  widget.onSettingsChanged(_currentTempSlider.toInt(), steps);
                }
              : null,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          child: AnimatedContainer(
            duration: AppConstants.animationFast,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: isDark ? 0.20 : 0.14)
                  : cs.surfaceContainerHighest.withValues(
                      alpha: isDark ? 0.40 : 0.50,
                    ),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.70)
                    : cs.outlineVariant.withValues(alpha: 0.30),
                width: isSelected ? 1.4 : 0.8,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? primaryColor : cs.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.9)
                        : cs.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
