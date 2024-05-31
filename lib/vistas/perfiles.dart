import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/app_locales.dart';

class Perfiles extends StatefulWidget {
  const Perfiles({super.key});
  @override
  State<Perfiles> createState() => _PerfilesState();
}

class _PerfilesState extends State<Perfiles> {
  late String _currentProfile = 'balanced';

  @override
  void initState() {
    _getCurrentProfile();
    super.initState();
  }

  Future<void> _getCurrentProfile() async {
    // Leer la variable que indica el perfil activo
    final process = await Process.run('getprop', ['sys.perfmtk.current_profile'], runInShell: true);
    final output = process.stdout as String;

    setState(() {
      _currentProfile = output.trim();
    });
  }

  Future<void> _setProfile(String profile) async {
    // Ejecutar el comando para establecer el perfil seleccionado
    await Process.run('su', ['-c', profile], runInShell: true);
    await _getCurrentProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${AppLocale.currentProfile.getString(context)}: $_currentProfile',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _currentProfile == 'performance'
                      ? null
                      : () async {
                          await _setProfile("performance");
                        },
                  child: Text(AppLocale.performance.getString(context)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _currentProfile == 'balanced'
                      ? null
                      : () async {
                          await _setProfile("balanced");
                        },
                  child: Text(AppLocale.balanced.getString(context)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
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
                  onPressed: _currentProfile == 'powersave'
                      ? null
                      : () async {
                          await _setProfile("powersave");
                        },
                  child: Text(AppLocale.powerSave.getString(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
