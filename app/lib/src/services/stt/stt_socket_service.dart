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

  Duration _speakingDuration = Duration.zero;

  DateTime? _sessionStartTime;
  DateTime? _lastTranscriptTime;

  Duration get speakingDuration => _speakingDuration;

  VoidCallback? onTranscriptUpdated;

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
      socket.emit('start-audio');
      _safeNotify();
    });

    /// STT 결과 수신
    socket.on('stt-result', (data) {
      final transcript =
          data is Map && data.containsKey('transcript')
              ? data['transcript']?.toString().trim()
              : null;
      final timestamp = data['timestamp'] as int?;

      if (transcript == null || transcript.isEmpty) return;

      if (timestamp != null) {
        final currentTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        _sessionStartTime ??= currentTime;
        _lastTranscriptTime = currentTime;
      }

      _transcript += '$transcript\n';

      final words = transcript.split(' ');
      for (final word in words) {
        if (!_sentWords.contains(word)) {
          _sentWords.add(word);
          _transcript += '$word ';
          onTranscriptUpdated?.call();
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
    final endTime = DateTime.now();
    socket.emit('end-audio');

    if (_sessionStartTime != null && _lastTranscriptTime != null) {
      final totalDuration = endTime.difference(_sessionStartTime!);
      final silentGap = endTime.difference(_lastTranscriptTime!);

      /// 침묵은 말 중단으로 간주하고 초기화
      /// 계산만 중단, stt는 계속 작동함
      /// 아래 if문에서 시간 조절 잘 해야하니 알아서 하시길..
      /// 참고로 시간은 ms 단위임
      final effectiveDuration =
          silentGap.inMilliseconds > 3000
              ? totalDuration - silentGap
              : totalDuration;

      _speakingDuration = effectiveDuration;
      _safeNotify();
    }
  }

  void clearTranscript() {
    _transcript = '';
    _speakingDuration = Duration.zero;
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
    if (socket.connected) {
      socket.disconnect();
    }
    super.dispose();
  }

  void startAudio() {
    socket.emit('start-audio');
  }
}
