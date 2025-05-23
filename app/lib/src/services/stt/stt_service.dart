import 'dart:async';
import 'dart:typed_data';

import 'package:permission_handler/permission_handler.dart';
import 'native_audio_stream.dart';
import 'stt_socket_service.dart';

class SttService {
  final NativeAudioStream _nativeAudio = NativeAudioStream();
  final SttSocketService _sttSocket = SttSocketService();

  Stream<Uint8List>? _audioStream;
  StreamSubscription<Uint8List>? _subscription;
  bool _isListening = false;

  bool get isListening => _isListening;
  String get transcript => _sttSocket.transcript;

  Future<void> init() async {
    await _sttSocket.connect();
  }

  Future<void> startListening(Function(String) onResult) async {
    final granted = await Permission.microphone.request();
    if (granted != PermissionStatus.granted) {
      throw Exception('🎙 마이크 권한이 필요합니다');
    }

    await _nativeAudio.start();
    _sttSocket.clearTranscript();
    _sttSocket.setOnTranscript(onResult);
    _sttSocket.startAudio();

    _audioStream = _nativeAudio.audioStream;
    _subscription = _audioStream?.listen((data) {
      _sttSocket.sendAudioChunk(data);
    });

    _isListening = true;
  }

  Future<void> stopListening() async {
    await _nativeAudio.stop();
    await _subscription?.cancel();
    _sttSocket.endAudio();

    _isListening = false;
  }

  void dispose() {
    _subscription?.cancel();
    _sttSocket.dispose();
  }
}
