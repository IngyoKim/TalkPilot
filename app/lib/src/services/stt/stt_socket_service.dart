import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SttSocketService with ChangeNotifier {
  late IO.Socket socket;

  bool _connected = false;
  bool get isConnected => _connected;

  String _transcript = '';
  String get transcript => _transcript;

  bool _disposed = false;

  void connect() {
    debugPrint('WebSocket 연결 시도 중...');

    socket = IO.io(
      'http://192.168.0.13:3000', // 서버 IP 주소
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      debugPrint('WebSocket 연결 성공');
      _connected = true;
      _safeNotify();
      socket.emit('start-audio');
    });

    socket.on('stt-result', (data) {
      debugPrint('STT 결과 수신: $data');
      _transcript += '$data\n';
      _safeNotify();
    });

    socket.onConnectError((err) {
      debugPrint('WebSocket 연결 실패: $err');
    });

    socket.onError((err) {
      debugPrint('WebSocket 에러: $err');
    });

    socket.onDisconnect((_) {
      debugPrint('WebSocket 연결 종료');
      _connected = false;
      _safeNotify();
    });

    socket.connect();
  }

  void sendAudioChunk(Uint8List chunk) {
    if (_connected) {
      socket.emit('audio-chunk', chunk);
    }
  }

  void endAudio() {
    socket.emit('end-audio');
  }

  void clearTranscript() {
    _transcript = '';
    _safeNotify();
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    socket.dispose();
    super.dispose();
  }
}
