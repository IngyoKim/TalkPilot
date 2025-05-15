import 'dart:typed_data';
import 'package:flutter/material.dart';

// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SttSocketService with ChangeNotifier {
  late IO.Socket socket;
  bool _connected = false;
  bool get isConnected => _connected;

  String _transcript = '';
  String get transcript => _transcript;

  bool _disposed = false;

  void connect() {
    final serverUrl = dotenv.env['NEST_SERVER_URL'];
    if (serverUrl == null || serverUrl.isEmpty) {
      debugPrint('환경변수 NEST_SERVER_URL 비어있습니다.');
      return;
    }

    debugPrint('WebSocket 연결 시도 중... [$serverUrl]');

    socket = IO.io(
      serverUrl,
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
