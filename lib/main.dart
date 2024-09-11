import 'package:flutter/material.dart';
import 'package:manager/app.dart';
import 'package:manager/config/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

