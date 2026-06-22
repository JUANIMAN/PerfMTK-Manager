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

  static const _enabledColors = [Color(0xFF1DB954), Color(0xFF0A8F3C)];
  static const _disabledColors = [Color(0xFFE53935), Color(0xFFB71C1C)];

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

    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        final t = _t.value;
        final grad = [
          Color.lerp(_disabledColors[0], _enabledColors[0], t)!,
          Color.lerp(_disabledColors[1], _enabledColors[1], t)!,
        ];

        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onChanged(!widget.isEnabled);
          },
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacing20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: grad,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
              boxShadow: [
                BoxShadow(
                  color: grad[0].withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacing14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  ),
                  child: AnimatedSwitcher(
                    duration: AppConstants.animationFast,
                    child: Icon(
                      widget.isEnabled
                          ? Icons.thermostat_auto_rounded
                          : Icons.thermostat_rounded,
                      key: ValueKey(widget.isEnabled),
                      color: Colors.white,
                      size: AppConstants.iconSizeXLarge,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),

                // State text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocale.thermalControl.getString(context),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w500,
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
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacing4),
                      Text(
                        widget.isEnabled
                            ? AppLocale.disableDsc.getString(context)
                            : AppLocale.enableDsc.getString(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),

                // Animated toggle pill
                AnimatedContainer(
                  duration: AppConstants.animationNormal,
                  width: 52,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedPositioned(
                        duration: AppConstants.animationNormal,
                        curve: Curves.easeOutCubic,
                        left: widget.isEnabled ? 26 : 2,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}