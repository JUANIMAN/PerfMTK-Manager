import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/services/system_service.dart';
import 'package:manager/widgets/current_state_card.dart';
import 'package:manager/widgets/thermal_switch.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Thermal extends StatefulWidget {
  const Thermal({super.key});

  @override
  State<Thermal> createState() => _ThermalState();
}

class _ThermalState extends State<Thermal> {
  String _currentThermal = '';

  @override
  void initState() {
    super.initState();
    _initializeThermalState();
  }

  Future<void> _initializeThermalState() async {
    final systemService = context.read<SystemService>();
    final thermalState = await systemService.getCurrentThermal();
    setState(() {
      _currentThermal = thermalState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemService>(
      builder: (context, systemService, child) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocale.titleThermal.getString(context),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                CurrentStateCard(
                  state: _currentThermal,
                  icon: _getThermalIcon(_currentThermal),
                  color: _getThermalColor(_currentThermal),
                  titleLocaleKey: 'thermalState',
                  stateLocaleKey: _currentThermal,
                ),
                const SizedBox(height: 32),
                ThermalSwitch(
                  key: ValueKey(_currentThermal),
                  isEnabled: _currentThermal == 'enabled',
                  onChanged: (bool value) async {
                    await _setThermalLimit(
                      context,
                      value ? 'enable' : 'disable',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _setThermalLimit(BuildContext context, String thermal) async {
    try {
      await context.read<SystemService>().setThermal(thermal);
      setState(() {
        _currentThermal = "${thermal}d";
      });
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
    final Uri url =
        Uri.parse('https://github.com/JUANIMAN/PerfMTK/releases/latest');
    try {
      await launchUrl(url);
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
        return Icons.thermostat_auto;
      case 'disabled':
        return Icons.thermostat;
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
