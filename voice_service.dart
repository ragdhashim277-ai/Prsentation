import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final FlutterTts _tts = FlutterTts();
  bool _stopped = false;

  Future<void> initialize() async {
    // يجعل speak() ينتظر حتى انتهاء النطق فنعرف متى ينتهي الصوت.
    await _tts.awaitSpeakCompletion(true);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.45);
  }

  Future<void> setRate(double rate) => _tts.setSpeechRate(rate);

  Future<void> _applyLanguage(String code) async {
    if (code == 'ar') {
      // نحاول استخدام صوت سوداني إن وُجد، وإلا العربية العامة.
      try {
        final voices = await _tts.getVoices;
        if (voices is List) {
          for (final v in voices) {
            if (v is Map &&
                (v['locale'] ?? '').toString().toLowerCase().replaceAll('_', '-') ==
                    'ar-sd') {
              await _tts.setVoice({
                'name': v['name'].toString(),
                'locale': v['locale'].toString(),
              });
              return;
            }
          }
        }
      } catch (_) {}
      await _tts.setLanguage('ar');
    } else {
      await _tts.setLanguage(code);
    }
  }

  /// يقسم النص إلى مقاطع قصيرة لأن محركات النطق ترفض النصوص الطويلة.
  List<String> _split(String text, {int maxLen = 600}) {
    final parts = text.split(RegExp(r'(?<=[\n.!؟?؛])'));
    final chunks = <String>[];
    var buffer = StringBuffer();
    for (final p in parts) {
      if (buffer.length + p.length > maxLen && buffer.isNotEmpty) {
        chunks.add(buffer.toString());
        buffer = StringBuffer();
      }
      buffer.write(p);
    }
    if (buffer.isNotEmpty) chunks.add(buffer.toString());
    return chunks.where((c) => c.trim().isNotEmpty).toList();
  }

  /// يعود عند انتهاء النطق أو عند الإيقاف.
  Future<void> speak(String text, {String languageCode = 'ar'}) async {
    _stopped = false;
    await _applyLanguage(languageCode);
    for (final chunk in _split(text)) {
      if (_stopped) break;
      await _tts.speak(chunk);
    }
  }

  Future<void> stop() async {
    _stopped = true;
    await _tts.stop();
  }
}
