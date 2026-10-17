import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:manager/config/theme.dart';
import 'package:manager/config/theme_provider.dart';
import 'package:manager/localization/app_locales.dart';
import 'package:manager/presentation/providers/app_profile_provider.dart';
import 'package:manager/presentation/navigator.dart' as app_navigator;

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    super.initState();
    final systemLanguage = Platform.localeName.split(RegExp(r'[_-]')).first;
    localization.init(
      mapLocales: [
        const MapLocale('en', AppLocale.en),
        const MapLocale('es', AppLocale.es),
      ],
      initLanguageCode: systemLanguage == 'es' ? 'es' : 'en',
    );
    localization.onTranslatedLanguage = _onTranslatedLanguage;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(appProfilesPreloadProvider, (_, _) {});
    });
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'PerfMTK Manager',
      supportedLocales: localization.supportedLocales,
      localizationsDelegates: localization.localizationsDelegates,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const app_navigator.AppNavigator(),
      debugShowCheckedModeBanner: false,
    );
  }
}
