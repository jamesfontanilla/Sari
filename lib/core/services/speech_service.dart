import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

class SpeechService {
  static final SpeechService instance = SpeechService._init();
  SpeechService._init();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: (val) => debugPrint('STT Error: $val'),
        onStatus: (val) => debugPrint('STT Status: $val'),
      );

      // Setup offline-first Filipino/English TTS
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5); // Natural speaking rate
      if (Platform.isAndroid) {
        // Tagalog voice fallback to English PH
        final languages = await _tts.getLanguages;
        if (languages.contains('fil-PH') || languages.contains('tl-PH')) {
          await _tts.setLanguage('fil-PH');
        } else {
          await _tts.setLanguage('en-PH');
        }
      }
    } catch (e) {
      debugPrint('Speech init failed: $e');
    }

    return _isInitialized;
  }

  Future<void> listen({
    required Function(String recognizedWords) onResult,
    required Function(bool isListening) onListeningChanged,
  }) async {
    final ready = await initialize();
    if (!ready) {
      onListeningChanged(false);
      return;
    }

    onListeningChanged(true);
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          onListeningChanged(false);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  Future<void> stop() async {
    await _speech.stop();
  }

  /// Sari speaks back to the store owner
  Future<void> speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }
}
