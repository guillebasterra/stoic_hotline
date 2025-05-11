import 'package:flutter/material.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Text(
                'Welcome to\nStoic Hotline',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleStyle,
              ),
              const SizedBox(height: 20),
              Text(
                'SELECT A PHILOSOPHER TO BEGIN!',
                style: AppTextStyles.subtitleStyle,
              ),
              // Philosopher selector will be added here next
            ],
          ),
        ),
      ),
    );
  }
} 