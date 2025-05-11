import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const StoicHotline());
}

class StoicHotline extends StatelessWidget {
  const StoicHotline({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stoic Hotline',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}


