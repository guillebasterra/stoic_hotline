import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicController {
  // Singleton instance
  static final MusicController _instance = MusicController._internal();

  factory MusicController() {
    return _instance;
  }

  MusicController._internal() {
    _loadPreferences();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isPlaying = prefs.getBool('musicEnabled') ?? false;

    // Automatically play music if it was enabled in the last session
    if (_isPlaying) {
      playMusic();
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', _isPlaying);
  }

  Future<void> playMusic() async {
    if (_isPlaying) return;

    await _audioPlayer.setSource(AssetSource('audio/b.mp3'));
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(0.5);
    await _audioPlayer.resume();

    _isPlaying = true;
    _savePreferences();
  }

  Future<void> stopMusic() async {
    if (!_isPlaying) return;

    await _audioPlayer.stop();
    _isPlaying = false;
    _savePreferences();
  }

  void toggleMusic() {
    
    if (_isPlaying) {
      stopMusic();
    } else {
      playMusic();
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}