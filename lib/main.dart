import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/music_controller.dart';


void main() {
  // Load environment variables from .env file
  dotenv.load(fileName: ".env");  

    // Start playing music
  final musicController = MusicController();
  musicController.playMusic();
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


