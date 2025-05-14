import 'package:audioplayers/audioplayers.dart';

class SoundEffectsController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playButtonClick() async {
    await _audioPlayer.play(AssetSource('audio/button_click.mp3'), volume: 0.5);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}