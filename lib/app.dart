import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager/config/theme.dart';
import 'package:manager/config/theme_provider.dart';
import 'package:manager/l10n/l10n.dart';
import 'package:manager/presentation/providers/app_profile_provider.dart';
import 'package:manager/presentation/navigator.dart' as app_navigator;

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(appProfilesPreloadProvider, (_, _) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'PerfMTK Manager',
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const app_navigator.AppNavigator(),
      debugShowCheckedModeBanner: false,
    );
  }
}
