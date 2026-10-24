import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/core/design/design.dart';

class ThermalSwitch extends StatefulWidget {
  final bool isEnabled;
  final bool isChanging;
  final ValueChanged<bool> onChanged;

  const ThermalSwitch({
    super.key,
    required this.isEnabled,
    this.isChanging = false,
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
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = widget.isEnabled
        ? AppPalette.neonGreen // Green (Protection active)
        : AppPalette.vividOrange; // Amber (Throttling bypassed)

    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh.withValues(alpha: 0.60),
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            border: Border.all(
              color: widget.isEnabled
                  ? activeColor.withValues(alpha: 0.35)
                  : AppPalette.vividOrange.withValues(alpha: 0.35),
              width: 1.0,
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
                      color: activeColor.withValues(alpha: isDark ? 0.16 : 0.10),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLarge),
                      border: Border.all(
                        color: activeColor.withValues(alpha: isDark ? 0.35 : 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: widget.isChanging
                        ? SizedBox(
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
                                  ? Icons.security_rounded
                                  : Icons.flash_on_rounded,
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
                          context.l10n.thermalControl,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing4),
                        AnimatedSwitcher(
                          duration: AppConstants.animationFast,
                          child: Text(
                            widget.isEnabled
                                ? 'Protección Térmica Activa (OEM)'
                                : 'Throttling Desactivado (Máximo Rendimiento)',
                            key: ValueKey(widget.isEnabled),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: activeColor,
                              fontWeight: FontWeight.w700,
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
                    onChanged: widget.isChanging
                        ? null
                        : (val) {
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
                    ? 'Los servicios térmicos del sistema (mi_thermald) regulan la temperatura. Si el equipo se calienta, limitarán la velocidad de carga, brillo o FPS.'
                    : 'Servicios térmicos del sistema deshabilitados. Previene caídas forzadas de FPS y permite la máxima tasa de carga sin estrangulamiento térmico de software.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
