import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/config/app_constants.dart';

class ThermalSwitch extends StatefulWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const ThermalSwitch({
    super.key,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  State<ThermalSwitch> createState() => _ThermalSwitchState();
}

class _ThermalSwitchState extends State<ThermalSwitch>
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
  void didUpdateWidget(ThermalSwitch old) {
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
    final activeColor = widget.isEnabled
        ? const Color(0xFF00E676)
        : const Color(0xFFFF5252);

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
                    child: AnimatedSwitcher(
                      duration: AppConstants.animationFast,
                      child: Icon(
                        widget.isEnabled
                            ? Icons.thermostat_auto_rounded
                            : Icons.thermostat_rounded,
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
                          AppLocale.thermalControl.getString(context),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing4),
                        AnimatedSwitcher(
                          duration: AppConstants.animationFast,
                          child: Text(
                            widget.isEnabled
                                ? AppLocale.enabled.getString(context)
                                : AppLocale.disabled.getString(context),
                            key: ValueKey(widget.isEnabled),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: activeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacing8),
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
                widget.isEnabled
                    ? AppLocale.disableDsc.getString(context)
                    : AppLocale.enableDsc.getString(context),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
