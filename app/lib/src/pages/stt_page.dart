import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/components/toast_message.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/services/stt/native_audio_stream.dart';
import 'package:talk_pilot/src/services/stt/stt_socket_service.dart';
import 'package:talk_pilot/src/utils/cpm_calculator.dart';

class SttPage extends StatefulWidget {
  const SttPage({super.key});

  @override
  State<SttPage> createState() => _SttPageState();
}

class _SttPageState extends State<SttPage> {
  final nativeAudio = NativeAudioStream();
  final CpmCalculator _cpmCalculator = CpmCalculator();
  Stream<Uint8List>? _audioStream;
  StreamSubscription<Uint8List>? _subscription;

  bool _isRecording = false;

  Future<void> _start(SttSocketService stt) async {
    final granted = await Permission.microphone.request();
    if (granted != PermissionStatus.granted) {
      ToastMessage.show('🎙 마이크 권한이 필요합니다.');
      return;
    }

    await nativeAudio.start();
    _audioStream = nativeAudio.audioStream;
    _subscription = _audioStream?.listen((data) {
      stt.sendAudioChunk(data);
    });

    _cpmCalculator.reset();

    stt.onTranscriptUpdated = () {
      _cpmCalculator.updateOnTranscriptChange();
    };

    setState(() => _isRecording = true);
  }

  Future<void> _stop(SttSocketService stt) async {
    await nativeAudio.stop();
    await _subscription?.cancel();
    stt.endAudio();

    final text = stt.transcript.trim();
    final cpm = _cpmCalculator.calculateCpm(text);

    if (text.isNotEmpty && cpm > 0) {
      final userProvider = context.read<UserProvider>();
      await userProvider.addCpm(cpm);
      if (mounted) {
        ToastMessage.show('CPM 저장됨: ${cpm.toStringAsFixed(1)}');
      }
    }

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
