import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';

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

    return Semantics(
      toggled: isEnabled,
      label: AppLocale.thermalControl.getString(context),
      value: isEnabled
          ? AppLocale.enabled.getString(context)
          : AppLocale.disabled.getString(context),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(context, theme),
              const SizedBox(height: 16),
              _buildSwitchContent(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, ThemeData theme) {
    return Text(
      AppLocale.thermalControl.getString(context),
      style: theme.textTheme.titleLarge,
    );
  }

  Widget _buildSwitchContent(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildSwitchDetails(context, theme),
        ),
        _buildAdaptiveSwitch(),
      ],
    );
  }

  Widget _buildSwitchDetails(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEnabled
              ? AppLocale.disable.getString(context)
              : AppLocale.enable.getString(context),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isEnabled
              ? AppLocale.disableDsc.getString(context)
              : AppLocale.enableDsc.getString(context),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildAdaptiveSwitch() {
    return Switch.adaptive(
      value: isEnabled,
      onChanged: onChanged,
      activeColor: Colors.green,
      inactiveThumbColor: Colors.red,
    );
  }
}
