import 'dart:typed_data';
import 'package:flutter/material.dart';

// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:talk_pilot/src/components/toast_message.dart';

class SttSocketService with ChangeNotifier {
  late IO.Socket socket;
  bool _connected = false;
  bool get isConnected => _connected;

  String _transcript = '';
  String get transcript => _transcript;

  bool _disposed = false;

  Future<void> connect() async {
    final serverUrl = dotenv.env['NEST_SERVER_URL'];
    if (serverUrl == null || serverUrl.isEmpty) {
      debugPrint('환경변수 NEST_SERVER_URL 비어있습니다.');
      ToastMessage.show('서버 주소가 설정되지 않았습니다.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Firebase 로그인 상태가 아닙니다.');
      ToastMessage.show('로그인 후 다시 시도해주세요.');
      return;
    }

    final idToken = await user.getIdToken();
    final authHeader = 'Bearer $idToken';

    debugPrint('WebSocket 연결 시도 중... [$serverUrl]');

    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': authHeader})
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
      ToastMessage.show('서버와 연결할 수 없습니다.');
    });

    socket.onError((err) {
      debugPrint('WebSocket 에러: $err');
      ToastMessage.show('WebSocket 에러가 발생했습니다.');
    });

    socket.onDisconnect((reason) {
      debugPrint('WebSocket 연결 종료: $reason');

      if (reason == 'io server disconnect') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ToastMessage.show('서버 인증에 실패했습니다.');
        });
      }

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
