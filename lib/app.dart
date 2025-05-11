// lib/app.dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

class StoicHotline extends StatelessWidget {
  const StoicHotline({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stoic Hotline',
      theme: AppTheme.lightTheme,
      home: const Scaffold(),
      // later: routes or Navigator 2.0
    );
  }
}
