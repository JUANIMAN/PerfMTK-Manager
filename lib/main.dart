import 'package:flutter/material.dart';
import 'package:manager/app.dart';
import 'package:manager/config/theme_provider.dart';
import 'package:manager/services/system_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SystemService()),
      ],
      child: const MyApp(),
    ),
  );
}
