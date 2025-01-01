import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/theme_provider.dart';
import 'package:manager/views/navegador.dart';
import 'package:manager/services/system_service.dart';
import 'package:provider/provider.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/config/theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    localization.init(
      mapLocales: [
        const MapLocale('en', AppLocale.EN),
        const MapLocale('es', AppLocale.ES),
      ],
      initLanguageCode: Platform.localeName.substring(0, 2) == 'es' ? 'es' : 'en',
    );
    localization.onTranslatedLanguage = _onTranslatedLanguage;
    super.initState();
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => SystemService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'PerfMTK Manager',
            supportedLocales: localization.supportedLocales,
            localizationsDelegates: localization.localizationsDelegates,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const Navegador(),
          );
        },
      ),
    );
  }
}
