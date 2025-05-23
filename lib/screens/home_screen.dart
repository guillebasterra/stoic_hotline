// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';

import '../core/theme/app_theme.dart';
import '../core/theme/text_styles.dart';
import '../core/music_controller.dart';           // ← import
import '../models/philosopher.dart';
import 'chat_screen.dart';
import 'package:animations/animations.dart';
import '../core/sound_effects_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SoundEffectsController _soundEffectsController = SoundEffectsController();
  int _currentIndex = 0;
  late PageController _pageController;
  List<Philosopher> philosophers = [];

  // NEW: music controller
  late final MusicController _musicController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);

    // NEW: instantiate controller
    _musicController = MusicController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPhilosophers();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // NEW: dispose audio resources
    super.dispose();
  }
  
  void _toggleMusic() {
    setState(() {
      _musicController.toggleMusic();
    });
  }

  Future<void> _loadPhilosophers() async {
    try {
      final String data = await DefaultAssetBundle.of(context)
          .loadString('assets/data/philosophers.json');
      final List<dynamic> jsonList = json.decode(data);
      setState(() {
        philosophers = jsonList
            .map((json) => Philosopher.fromJson(json))
            .toList();
      });
    } catch (e) {
      debugPrint('Error loading philosophers: $e');
    }
  }

  // NEW: show settings dialog
void _showSettings() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Settings', style: AppTextStyles.titleStyle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Background Music', style: AppTextStyles.subtitleStyle),
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return Switch(
                    value: _musicController.isPlaying,
                    onChanged: (enabled) {
                      _musicController.toggleMusic();
                      setDialogState(() {});
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sound Effects', style: AppTextStyles.subtitleStyle),
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return Switch(
                    value: _soundEffectsController.isEnabled,
                    onChanged: (enabled) {
                      _soundEffectsController.toggleSoundEffects();
                      setDialogState(() {});
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _soundEffectsController.playButtonClick();
            Navigator.of(context).pop();
          },
          child: Text('Close', style: AppTextStyles.buttonStyle),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // NEW: AppBar with settings icon
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings,
                color: AppTheme.lightTheme.colorScheme.onSurface),
            onPressed: () {
              _soundEffectsController.playButtonClick();
              _showSettings();
            },
          ),
        ],
      ),

      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
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
              const SizedBox(height: 30),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Philosopher carousel
                    SizedBox(
                      height: 300,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemCount: philosophers.length,
                        itemBuilder: (context, index) {
                          final phil = philosophers.isNotEmpty
                              ? philosophers[index]
                              : Philosopher(
                                  id: 0,
                                  name: 'Loading...',
                                  image: '',
                                  quotes: '',
                                );
                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _currentIndex == index ? 1.0 : 0.5,
                            child: PhilosopherCard(
                              philosopher: phil,
                              isSelected: _currentIndex == index,
                            ),
                          );
                        },
                      ),
                    ),

                    // Navigation arrows
                    Positioned(
                      left: 10,
                      child: IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          size: 40,
                        ),
                        onPressed: () {
                          _soundEffectsController.playButtonClick();
                          final prevPage = (_currentIndex - 1 + philosophers.length) % philosophers.length;
                          _pageController.animateToPage(
                            prevPage,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        tooltip: 'Previous',
                      ),
                    ),
                    Positioned(
                      right: 10,
                      child: IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          size: 40,
                        ),
                        onPressed: () {
                          _soundEffectsController.playButtonClick();
                          final nextPage = (_currentIndex + 1) % philosophers.length;
                          _pageController.animateToPage(
                            nextPage,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Philosopher name
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  philosophers.isEmpty
                      ? 'Loading...'
                      : philosophers[_currentIndex].name,
                  style: AppTextStyles.subtitleStyle,
                ),
              ),

              // Select button
              OpenContainer(
                transitionDuration: const Duration(milliseconds: 400),
                closedElevation: 0,
                openElevation: 4,
                closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                openShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                closedColor: Theme.of(context).colorScheme.primary,
                openColor: const Color.fromARGB(255, 255, 255, 255),
                closedBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        _soundEffectsController.playButtonClick();
                        openContainer();
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: AppTextStyles.buttonStyle,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('SELECT'),
                    ),
                  );
                },
                openBuilder: (BuildContext context, VoidCallback _) {
                  final selected = philosophers[_currentIndex];
                  return ChatScreen(philosopher: selected);
                },
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class PhilosopherCard extends StatelessWidget {
  final Philosopher philosopher;
  final bool isSelected;

  const PhilosopherCard({
    super.key,
    required this.philosopher,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(isSelected ? 1.0 : 0.85),
      child: philosopher.image.isEmpty
          ? const CircularProgressIndicator()
          : Image.asset(
              philosopher.image,
              height: 250,
              fit: BoxFit.contain,
            ),
    );
  }
}
