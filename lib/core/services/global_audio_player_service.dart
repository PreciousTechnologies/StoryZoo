import 'package:audioplayers/audioplayers.dart';

class GlobalAudioPlayerService {
  GlobalAudioPlayerService._();

  static final GlobalAudioPlayerService instance = GlobalAudioPlayerService._();

  final AudioPlayer player = AudioPlayer();

  Future<void> togglePlayPause() async {
    final state = player.state;
    if (state == PlayerState.playing) {
      await player.pause();
    } else {
      await player.resume();
    }
  }

  Future<void> stop() async {
    await player.stop();
  }
}
