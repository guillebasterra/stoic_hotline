import 'package:flutter/material.dart';
import 'text_styles.dart';

class AppTheme {
  // Light theme
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Jersey 10',
    scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 214),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFD69090),
      brightness: Brightness.light,
      primary: const Color(0xFFD69090),
      secondary: Colors.brown.shade700,
      surface: const Color.fromARGB(255, 172, 172, 172),
    ),
    textTheme: TextTheme(
      titleLarge: AppTextStyles.titleStyle,
      titleMedium: AppTextStyles.subtitleStyle,
      bodyLarge: AppTextStyles.bodyStyle,
      labelLarge: AppTextStyles.buttonStyle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD69090),
        foregroundColor: Colors.brown.shade700,
        textStyle: AppTextStyles.buttonStyle,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
