import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/widgets/current_state_card.dart';
import 'package:manager/widgets/thermal_switch.dart';
import 'package:url_launcher/url_launcher.dart';

class Thermal extends StatefulWidget {
  const Thermal({super.key});

  @override
  State<Thermal> createState() => _ThermalState();
}

class _ThermalState extends State<Thermal> with SingleTickerProviderStateMixin {
  final Uri _url = Uri.parse('https://github.com/JUANIMAN/PerfMTK/releases/latest');
  String _thermalState = '';

  @override
  void initState() {
    super.initState();
    _getThermalState();
  }

  Future<void> _getThermalState() async {
    final process = await Process.run('getprop', ['sys.perfmtk.thermal_state']);
    final output = process.stdout as String;

    setState(() {
      _thermalState = output.trim();
    });
  }

  Future<void> _setThermalLimit(String thermal) async {
    try {
      final process = await Process.run('su', ['-c', 'thermal_limit', thermal]);
      final output = process.stderr as String;

      if (output.contains('inaccessible or not found')) {
        _showErrorSnackBar();
      } else {
        await _getThermalState();
      }
    } catch (e) {
      _showErrorSnackBar();
    }
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocale.snackBarText.getString(context)),
        action: SnackBarAction(
          label: AppLocale.snackBarLabel.getString(context),
          onPressed: _launchUrl,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _launchUrl() async {
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocale.titleThermal.getString(context),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            CurrentStateCard(
              state: _thermalState,
              icon: _getThermalIcon(_thermalState),
              color: _getThermalColor(_thermalState),
              titleLocaleKey: 'thermalState',
              stateLocaleKey: _thermalState,
            ),
            const SizedBox(height: 32),
            ThermalSwitch(
              isEnabled: _thermalState == 'enabled',
              onChanged: (bool value) async {
                await _setThermalLimit(value ? 'enable' : 'disable');
              },
            ),
          ],
        ),
      ),
    );
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
