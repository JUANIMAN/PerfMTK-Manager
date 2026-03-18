import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/data/models/system_state.dart';
import 'package:manager/presentation/providers/system_provider.dart';
import 'package:manager/presentation/widgets/current_state_card.dart';
import 'package:manager/presentation/widgets/thermal_switch.dart';
import 'package:manager/config/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ThermalScreen extends ConsumerWidget {
  const ThermalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemState = ref.watch(systemStateProvider);

    return Scaffold(
      body: systemState.when(
        data: (state) => _buildContent(context, ref, state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorView(context, ref, error),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, SystemState state) {
    final isChanging = ref.watch(isChangingThermalProvider);

    return Padding(
      padding: AppConstants.paddingNormal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocale.titleThermal.getString(context),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacing24),
          CurrentStateCard(
            state: state.thermalState.value,
            icon: _getThermalIcon(state.thermalState),
            color: _getThermalColor(state.thermalState),
            titleLocaleKey: 'thermalState',
            stateLocaleKey: state.thermalState.value,
            isLoading: isChanging,
          ),
          const SizedBox(height: AppConstants.spacing32),
          IgnorePointer(
            ignoring: isChanging,
            child: AnimatedOpacity(
              duration: AppConstants.animationFast,
              opacity: isChanging ? AppConstants.opacityDisabled : 1.0,
              child: ThermalSwitch(
                key: ValueKey(state.thermalState),
                isEnabled: state.thermalState == ThermalState.enabled,
                onChanged: (value) => _setThermalLimit(context, ref, value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            AppLocale.snackBarText.getString(context),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () => ref.refresh(systemStateProvider),
              ),
              const SizedBox(width: AppConstants.spacing8),
              OutlinedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: Text(AppLocale.snackBarLabel.getString(context)),
                onPressed: () => _launchUrl(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _setThermalLimit(BuildContext context, WidgetRef ref, bool enabled) {
    HapticFeedback.mediumImpact();
    final thermalState =
    enabled ? ThermalState.enabled : ThermalState.disabled;
    ref.read(systemStateProvider.notifier).setThermalState(thermalState);
  }

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.parse('https://github.com/JUANIMAN/PerfMTK/releases/latest');
    try {
      await launchUrl(uri);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocale.downloadMess.getString(context)),
          ),
        );
      }
    }
  }

  IconData _getThermalIcon(ThermalState state) {
    switch (state) {
      case ThermalState.enabled:
        return Icons.thermostat_auto;
      case ThermalState.disabled:
        return Icons.thermostat;
    }
  }

  Color _getThermalColor(ThermalState state) {
    switch (state) {
      case ThermalState.enabled:
        return Colors.green;
      case ThermalState.disabled:
        return Colors.red;
    }
  }
}