import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/core/design/design.dart';

class ChargeBypassCard extends StatefulWidget {
  final bool isEnabled;
  final bool hasHardwareBypass;
  final int? batteryTempC;
  final bool isChanging;
  final ValueChanged<bool> onChanged;

  const ChargeBypassCard({
    super.key,
    required this.isEnabled,
    this.hasHardwareBypass = false,
    this.batteryTempC,
    this.isChanging = false,
    required this.onChanged,
  });

  @override
  State<ChargeBypassCard> createState() => _ChargeBypassCardState();
}

class _ChargeBypassCardState extends State<ChargeBypassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _t;


  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppConstants.animationNormal,
      value: widget.isEnabled ? 1.0 : 0.0,
    );
    _t = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(ChargeBypassCard old) {
    super.didUpdateWidget(old);
    if (widget.isEnabled != old.isEnabled) {
      widget.isEnabled ? _ctrl.forward() : _ctrl.reverse();
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
    const activeColor = AppPalette.vividOrange;

    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            border: Border.all(
              color: widget.isEnabled
                  ? activeColor.withValues(alpha: 0.35)
                  : cs.outlineVariant.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row ───────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacing12),
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLarge),
                    ),
                    child: widget.isChanging
                        ? const SizedBox(
                            width: AppConstants.iconSizeLarge,
                            height: AppConstants.iconSizeLarge,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(activeColor),
                            ),
                          )
                        : AnimatedSwitcher(
                            duration: AppConstants.animationFast,
                            child: Icon(
                              widget.isEnabled
                                  ? Icons.bolt_rounded
                                  : Icons.power_off_rounded,
                              key: ValueKey(widget.isEnabled),
                              color: activeColor,
                              size: AppConstants.iconSizeLarge,
                            ),
                          ),
                  ),
                  const SizedBox(width: AppConstants.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.hasHardwareBypass
                              ? context.l10n.hwChargeBypassTitle
                              : context.l10n.smartFastChargeTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing4),
                        AnimatedSwitcher(
                          duration: AppConstants.animationFast,
                          child: Text(
                            widget.isChanging
                                ? context.l10n.applying
                                : (widget.isEnabled
                                    ? (widget.hasHardwareBypass
                                        ? context.l10n.hwBypassActive
                                        : context.l10n.smartFastChargeActive)
                                    : (widget.hasHardwareBypass
                                        ? context.l10n.hwBypassInactive
                                        : context.l10n.smartFastChargeInactive)),
                            key: ValueKey(
                                '${widget.isEnabled}-${widget.isChanging}-${widget.hasHardwareBypass}'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: widget.isEnabled
                                  ? activeColor
                                  : cs.onSurfaceVariant,
                              fontWeight: widget.isEnabled
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
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
                      activeThumbColor: activeColor,
                      onChanged: (val) {
                        HapticFeedback.mediumImpact();
                        widget.onChanged(val);
                      },
                    ),
                ],
              ),

              // ── Description ───────────────────────────────────────────
              const SizedBox(height: AppConstants.spacing12),
              Text(
                widget.hasHardwareBypass
                    ? context.l10n.hwChargeBypassDesc
                    : context.l10n.smartFastChargeDesc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),

              // ── Metrics Strip (BatteryCareCard style) ──────────────────
              const SizedBox(height: AppConstants.spacing14),
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.20),
              ),
              const SizedBox(height: AppConstants.spacing12),
              Wrap(
                spacing: AppConstants.spacing12,
                runSpacing: AppConstants.spacing6,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.18),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.thermostat_rounded,
                          size: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.batteryTempC != null
                              ? '${context.l10n.batteryTemp}: ${widget.batteryTempC}°C'
                              : '${context.l10n.batteryTemp}: --',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.18),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${context.l10n.safetyGuardLimit}: 48°C',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}