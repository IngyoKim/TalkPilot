import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/services/stt/native_audio_stream.dart';
import 'package:talk_pilot/src/services/stt/stt_socket_service.dart';

class SttPage extends StatefulWidget {
  const SttPage({super.key});

  @override
  State<SttPage> createState() => _SttPageState();
}

class _SttPageState extends State<SttPage> {
  final nativeAudio = NativeAudioStream();
  Stream<Uint8List>? _audioStream;
  StreamSubscription<Uint8List>? _subscription;

  bool _isRecording = false;

  Future<void> _start(SttSocketService stt) async {
    final granted = await Permission.microphone.request();
    if (granted != PermissionStatus.granted) {
      throw Exception('🎙 마이크 권한 필요');
    }

    await nativeAudio.start();
    _audioStream = nativeAudio.audioStream;
    _subscription = _audioStream?.listen((data) {
      stt.sendAudioChunk(data);
    });

    setState(() => _isRecording = true);
  }

  Future<void> _stop(SttSocketService stt) async {
    await nativeAudio.stop();
    await _subscription?.cancel();
    stt.endAudio();
    setState(() => _isRecording = false);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SttSocketService()..connect(),
      child: Scaffold(
        appBar: AppBar(title: const Text('실시간 STT')),
        body: Consumer<SttSocketService>(
          builder: (context, stt, _) {
            return Column(
              children: [
                if (!stt.isConnected)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '연결 중...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      stt.transcript,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<SttSocketService>().clearTranscript();
                      },
                      child: const Text('초기화'),
                    ),
                    ElevatedButton(
                      onPressed: _isRecording ? null : () => _start(stt),
                      child: const Text('녹음 시작'),
                    ),
                    ElevatedButton(
                      onPressed: _isRecording ? () => _stop(stt) : null,
                      child: const Text('녹음 종료'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
