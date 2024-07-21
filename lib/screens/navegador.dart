import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/screens/perfiles.dart';
import 'package:manager/screens/thermal.dart';

class Navegador extends StatefulWidget {
  final Function toggleTheme;
  final ThemeMode themeMode;

  const Navegador({super.key, required this.toggleTheme, required this.themeMode});

  @override
  State<Navegador> createState() => _NavegadorState();
}

class _NavegadorState extends State<Navegador> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PerfMTK Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.toggleTheme(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _indice,
        children: const [
          Perfiles(),
          Thermal(),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: NavigationBar(
            selectedIndex: _indice,
            onDestinationSelected: (int index) {
              setState(() {
                _indice = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.tune),
                label: AppLocale.profiles.getString(context),
              ),
              NavigationDestination(
                icon: const Icon(Icons.thermostat),
                label: AppLocale.thermal.getString(context),
              ),
            ],
            animationDuration: const Duration(milliseconds: 300),
          ),
        ),
      ),
    );
  }
}
