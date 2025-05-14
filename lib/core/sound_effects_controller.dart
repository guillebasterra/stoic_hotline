import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundEffectsController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isEnabled = true;

  SoundEffectsController() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('soundEffectsEnabled') ?? true;
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEffectsEnabled', _isEnabled);
  }

  Future<void> playButtonClick() async {
    if (_isEnabled) {
      await _audioPlayer.play(AssetSource('audio/button.mp3'), volume: 0.5);
    }
  }

  void toggleSoundEffects() {
    _isEnabled = !_isEnabled;
    _savePreferences();
  }

  bool get isEnabled => _isEnabled;

  void dispose() {
    _audioPlayer.dispose();
  }
}