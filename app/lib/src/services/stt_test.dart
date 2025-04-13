import 'package:speech_to_text/speech_to_text.dart' as stt;

class SttService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;

  bool get isListening => _speech.isListening;

  Future<void> init() async {
    _isAvailable = await _speech.initialize(
      onStatus: (status) => print('STT status: $status'),
      onError: (error) => print('STT error: $error'),
    );
  }

  Future<void> startListening(Function(String) onResult) async {
    if (_isAvailable && !_speech.isListening) {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
      );
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}
