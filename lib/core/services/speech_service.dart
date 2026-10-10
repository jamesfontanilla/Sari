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

      // Setup natural Filipino/Taglish TTS
      await _tts.setPitch(1.18); // Warm, energetic tindera mascot pitch
      await _tts.setSpeechRate(0.52); // Natural Tagalog conversational cadence

      if (Platform.isAndroid) {
        try {
          final voices = await _tts.getVoices;
          Map<String, String>? chosenVoice;
          if (voices is List) {
            for (var v in voices) {
              if (v is Map) {
                final locale = v['locale']?.toString() ?? '';
                final name = v['name']?.toString() ?? '';
                // Target native Filipino voice (fil-PH, tl-PH)
                if (locale.toLowerCase().contains('fil') || locale.toLowerCase().contains('tl')) {
                  if (name.contains('local') || name.contains('fic') || name.contains('fie')) {
                    chosenVoice = {'name': name, 'locale': locale};
                    break;
                  }
                  chosenVoice ??= {'name': name, 'locale': locale};
                }
              }
            }
          }

          if (chosenVoice != null) {
            await _tts.setVoice(chosenVoice);
            await _tts.setLanguage(chosenVoice['locale'] ?? 'fil-PH');
          } else {
            final languages = await _tts.getLanguages;
            if (languages.contains('fil-PH') || languages.contains('tl-PH')) {
              await _tts.setLanguage('fil-PH');
            } else if (languages.contains('en-PH')) {
              await _tts.setLanguage('en-PH');
            } else {
              await _tts.setLanguage('en-US');
            }
          }
        } catch (e) {
          debugPrint('Voice selection error: $e');
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
      final normalized = _normalizeTextForSpeech(text);
      await _tts.speak(normalized);
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  /// Normalizes currency, units, and markdown for natural Tagalog/English speech
  String _normalizeTextForSpeech(String text) {
    var out = text;
    // Strip markdown formatting that sounds robotic
    out = out.replaceAll(RegExp(r'\*\*|__|\*|_|#+'), '');
    out = out.replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1');

    // Currency symbols: ₱150 -> 150 pesos
    out = out.replaceAllMapped(RegExp(r'₱\s*(\d+(\.\d+)?)'), (m) => '${m[1]} pesos');
    out = out.replaceAll('₱', 'pesos');

    // Common abbreviations
    out = out.replaceAll(RegExp(r'\b(\d+)\s*pcs\b', caseSensitive: false), r'$1 piraso');
    out = out.replaceAll(RegExp(r'\b(\d+)\s*pc\b', caseSensitive: false), r'$1 piraso');
    out = out.replaceAll(RegExp(r'\b(\d+)\s*kls\b', caseSensitive: false), r'$1 kilo');
    out = out.replaceAll(RegExp(r'\b(\d+)\s*kg\b', caseSensitive: false), r'$1 kilo');
    out = out.replaceAll(RegExp(r'\bvs\.\b', caseSensitive: false), 'kumpara sa');

    return out.trim();
  }
}
