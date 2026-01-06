import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/config/app_constants.dart';

class ThermalSwitch extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const ThermalSwitch({
    super.key,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isEnabled ? Colors.green : Colors.red;

    return AppCard(
      elevation: AppConstants.elevationSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isEnabled ? Icons.check_circle_outline : Icons.highlight_off,
                color: color,
                size: AppConstants.iconSizeMedium,
              ),
              const SizedBox(width: AppConstants.spacing8),
              Text(
                AppLocale.thermalControl.getString(context),
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnabled
                          ? AppLocale.disable.getString(context)
                          : AppLocale.enable.getString(context),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    Text(
                      isEnabled
                          ? AppLocale.disableDsc.getString(context)
                          : AppLocale.enableDsc.getString(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  onChanged(value);
                },
                activeThumbColor: Colors.green,
                inactiveThumbColor: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}