import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _playing = false;

  /// Mainkan sirine darurat. Loop terus hingga [stop] dipanggil.
  static Future<void> playAlarm() async {
    if (_playing) return;
    try {
      _playing = true;
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('audio/alarm.mp3'));
    } catch (e) {
      _playing = false;
      debugPrint('[Audio] Failed to play alarm: $e');
    }
  }

  /// Hentikan sirine.
  static Future<void> stop() async {
    if (!_playing) return;
    _playing = false;
    await _player.stop();
  }

  static bool get isPlaying => _playing;
}
