// lib/services/audio_tour_service.dart
import 'package:flutter_tts/flutter_tts.dart';

class AudioTourService {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;

  static Future<void> _ensureInit() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  static Future<void> playDestinationTour(String script) async {
    await _ensureInit();
    await _tts.speak(script);
  }

  static Future<void> stop() => _tts.stop();

  static void setCompletionHandler(void Function() handler) {
    _tts.setCompletionHandler(handler);
  }
}
