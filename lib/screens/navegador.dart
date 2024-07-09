import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/screens/perfiles.dart';
import 'package:manager/screens/thermal.dart';

class Navegador extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const Navegador({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  State<Navegador> createState() => _NavegadorState();
}

class _NavegadorState extends State<Navegador> {
  final List<Widget> _cuerpo = [const Perfiles(), const Thermal()];
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PerfMTK Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body: _cuerpo[_indice],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indice,
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
