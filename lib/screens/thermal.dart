import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/services/system_service.dart';
import 'package:manager/widgets/current_state_card.dart';
import 'package:manager/widgets/thermal_switch.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Thermal extends StatelessWidget {
  const Thermal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemService>(
      builder: (context, systemService, child) {
        return FutureBuilder<String>(
          future: systemService.getCurrentThermal(),
          builder: (context, snapshot) {
            final thermalState = snapshot.data ?? '';
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocale.titleThermal.getString(context),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        CurrentStateCard(
                          state: thermalState,
                          icon: _getThermalIcon(thermalState),
                          color: _getThermalColor(thermalState),
                          titleLocaleKey: 'thermalState',
                          stateLocaleKey: thermalState,
                        ),
                        const SizedBox(height: 32),
                        ThermalSwitch(
                          isEnabled: thermalState == 'enabled',
                          onChanged: (bool value) async {
                            await _setThermalLimit(context, value ? 'enable' : 'disable');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _setThermalLimit(BuildContext context, String thermal) async {
    try {
      await context.read<SystemService>().setThermal(thermal);
    } catch (e) {
      _showErrorSnackBar(context);
    }
  }

  void _showErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocale.snackBarText.getString(context)),
        action: SnackBarAction(
          label: AppLocale.snackBarLabel.getString(context),
          onPressed: () => _launchUrl(context),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context) async {
    final Uri _url =
        Uri.parse('https://github.com/JUANIMAN/PerfMTK/releases/latest');
    try {
      await launchUrl(_url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocale.downloadMess.getString(context)),
        ),
      );
    }
  }

  IconData _getThermalIcon(String state) {
    switch (state) {
      case 'enabled':
        return Icons.thermostat;
      case 'disabled':
        return Icons.thermostat_auto;
      default:
        return Icons.help_outline;
    }
  }

  Color _getThermalColor(String state) {
    switch (state) {
      case 'enabled':
        return Colors.green;
      case 'disabled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
