import 'package:audioplayers/audioplayers.dart';

class MusicController {
  // Singleton instance
  static final MusicController _instance = MusicController._internal();

  factory MusicController() {
    return _instance;
  }

  MusicController._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> playMusic() async {
    if (_isPlaying) return;

    await _audioPlayer.setSource(AssetSource('audio/b.mp3'));
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(0.5);
    await _audioPlayer.resume();

    _isPlaying = true;
  }

  Future<void> stopMusic() async {
    if (!_isPlaying) return;

    await _audioPlayer.stop();
    _isPlaying = false;
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