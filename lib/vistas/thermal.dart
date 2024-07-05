import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/app_locales.dart';

class Thermal extends StatefulWidget {
  const Thermal({super.key});
  @override
  State<Thermal> createState() => _ThermalState();
}

class _ThermalState extends State<Thermal> {
  String _thermalState = 'enabled';

  @override
  void initState() {
    _getThermalState();
    super.initState();
  }

  Future<void> _getThermalState() async {
    // Obtener el estado actual de la limitación térmica
    final process = await Process.run('getprop', ['sys.perfmtk.thermal_state'], runInShell: true);
    final output = process.stdout as String;
    setState(() {
      _thermalState = output.trim();
    });
  }

  Future<void> _setThermalLimit(String thermal) async {
    // Ejecutar el comando para activar/desactivar la limitación térmica
    await Process.run('su', ['-c', 'thermal_limit', thermal], runInShell: true);
    await _getThermalState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${AppLocale.thermalState.getString(context)}: $_thermalState',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _thermalState == 'enabled'
                      ? null
                      : () async {
                          await _setThermalLimit("enable");
                        },
                  child: Text(AppLocale.enable.getString(context)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 260,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _thermalState == 'disabled'
                      ? null
                      : () async {
                          await _setThermalLimit("disable");
                        },
                  child: Text(AppLocale.disable.getString(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
