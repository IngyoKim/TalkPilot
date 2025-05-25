import 'dart:typed_data';
import 'package:flutter/material.dart';
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

  final Set<String> _sentWords = {};
  Function(String)? _onTranscript;

  void setOnTranscript(Function(String) callback) {
    _onTranscript = callback;
  }

  Future<void> connect() async {
    final serverUrl = dotenv.env['NEST_SERVER_URL'];
    if (serverUrl == null || serverUrl.isEmpty) {
      ToastMessage.show('서버 주소가 설정되지 않았습니다.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastMessage.show('로그인 후 다시 시도해주세요.');
      return;
    }

    final idToken = await user.getIdToken();
    final authHeader = 'Bearer $idToken';

    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': authHeader})
          .build(),
    );

    socket.onConnect((_) {
      _connected = true;
      _safeNotify();
      socket.emit('start-audio');
    });

    socket.on('stt-result', (data) {
      final transcript =
          data is Map && data.containsKey('transcript')
              ? data['transcript']?.toString().trim()
              : null;

      if (transcript == null || transcript.isEmpty) return;

      final words = transcript.split(' ');

      for (final word in words) {
        if (!_sentWords.contains(word)) {
          _sentWords.add(word);
          _transcript += '$word ';
          _onTranscript?.call(transcript);
          _safeNotify();
        }
      }
    });

    socket.onConnectError((err) {
      ToastMessage.show('서버와 연결할 수 없습니다.');
    });

    socket.onError((err) {
      ToastMessage.show('WebSocket 에러가 발생했습니다.');
    });

    socket.onDisconnect((reason) {
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
    _sentWords.clear();
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

  void startAudio() {
    socket.emit('start-audio');
  }
}
