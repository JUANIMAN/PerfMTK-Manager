import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/app_locales.dart';
import 'package:manager/vistas/perfiles.dart';
import 'package:manager/vistas/thermal.dart';

class Navegador extends StatefulWidget {
  const Navegador({super.key});
  @override
  State<Navegador> createState() => _NavegadorState();
}

class _NavegadorState extends State<Navegador> {
  final FlutterLocalization localization = FlutterLocalization.instance;
  final _cuerpo = [const Perfiles(), const Thermal()];
  final items = ['English', 'Español'];
  int _indice = 0;

  void _setLocale(String? value) {
    switch (value) {
      case 'English':
        return localization.translate('en');
      case 'Español':
        return localization.translate('es');
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _indice == 0
            ? Text(AppLocale.titleProfiles.getString(context))
            : Text(AppLocale.titleThermal.getString(context)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.only(left: 15.0, right: 5.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<String>(
              value: localization.getLanguageName(),
              onChanged: (String? newValue) {
                _setLocale(newValue);
              },
              items: items
                  .map<DropdownMenuItem<String>>(
                      (value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                  .toList(),
              icon: const Icon(Icons.arrow_drop_down),
              underline: const SizedBox(),
            ),
          ),
        ],
      ),
      body: _cuerpo[_indice],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indice,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.tune),
            label: AppLocale.profiles.getString(context),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.ac_unit),
            label: AppLocale.thermal.getString(context),
          )
        ],
        onTap: (value) {
          setState(() {
            _indice = value;
          });
        },
      ),
    );
  }
}
