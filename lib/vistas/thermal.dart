import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/app_locales.dart';
import 'package:url_launcher/url_launcher.dart';

class Thermal extends StatefulWidget {
  const Thermal({super.key});

  @override
  State<Thermal> createState() => _ThermalState();
}

class _ThermalState extends State<Thermal> {
  final Uri _url = Uri.parse('https://github.com/JUANIMAN/PerfMTK/releases');
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
      await Process.run('su', ['-c', 'thermal_limit', thermal]);
      await _getThermalState();
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
          onPressed: () {
            _launchUrl();
          },
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
            _buildThermalStateCard(
              context,
              _thermalState,
              _getThermalIcon(_thermalState),
              _getThermalColor(_thermalState),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocale.titleThermal.getString(context),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildThermalSwitch(),
          ],
        ),
      ),
    );
  }

  Widget _buildThermalStateCard(
      BuildContext context, String state, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocale.currentProfile.getString(context),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      AppLocale.getValue(state).getString(context),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThermalSwitch() {
    final isEnabled = _thermalState == 'enabled';
    return SwitchListTile(
      title: Text(
        isEnabled
            ? AppLocale.disable.getString(context)
            : AppLocale.enable.getString(context),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        isEnabled
            ? AppLocale.disableSub.getString(context)
            : AppLocale.enableSub.getString(context),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      value: isEnabled,
      onChanged: (bool value) async {
        await _setThermalLimit(value ? 'enable' : 'disable');
      },
      activeColor: Colors.green,
      inactiveThumbColor: Colors.red,
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
