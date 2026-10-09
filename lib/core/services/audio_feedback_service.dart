import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioFeedbackService {
  static final AudioFeedbackService instance = AudioFeedbackService._internal();
  AudioPlayer? _player;

  AudioFeedbackService._internal() {
    _initPlayer();
  }

  void _initPlayer() {
    try {
      _player = AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);
    } catch (_) {}
  }

  /// Play transaction confirmation chime ("ka-ching!")
  Future<void> playKaChing() async {
    try {
      HapticFeedback.mediumImpact();
      _player?.stop();
      await _player?.play(AssetSource('sounds/cash_register.wav'), volume: 0.9);
    } catch (_) {
      // Fallback to system haptics
      HapticFeedback.heavyImpact();
    }
  }

  /// Play barcode scanner confirmation beep
  Future<void> playScanBeep() async {
    try {
      HapticFeedback.lightImpact();
      _player?.stop();
      await _player?.play(AssetSource('sounds/beep.wav'), volume: 0.8);
    } catch (_) {
      HapticFeedback.selectionClick();
    }
  }

  void dispose() {
    _player?.dispose();
  }
}
