import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:talk_pilot/src/utils/cpm_calculator.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/components/toast_message.dart';
import 'package:talk_pilot/src/services/stt/stt_socket_service.dart';
import 'package:talk_pilot/src/services/stt/native_audio_stream.dart';

class SttPage extends StatefulWidget {
  const SttPage({super.key});

  @override
  State<SttPage> createState() => _SttPageState();
}

class _SttPageState extends State<SttPage> {
  final nativeAudio = NativeAudioStream();
  final CpmCalculator _cpmCalculator = CpmCalculator();
  StreamSubscription<Uint8List>? _subscription;

  bool _isRecording = false;

  Future<void> _start(SttSocketService stt) async {
    final granted = await Permission.microphone.request();
    if (granted != PermissionStatus.granted) {
      ToastMessage.show('🎙 마이크 권한이 필요합니다.');
      return;
    }

    await nativeAudio.start();
    _subscription?.cancel();
    _subscription = nativeAudio.audioStream.listen((data) {
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
    _subscription = null;

    stt.endAudio();

    final text = stt.transcript.trim();
    final cpm = _cpmCalculator.calculateCpm(text);

    if (text.isNotEmpty && cpm > 0) {
      // ignore: use_build_context_synchronously
      final userProvider = context.read<UserProvider>();
      await userProvider.addCpm(cpm);
      if (mounted) {
        ToastMessage.show('CPM 저장됨: ${cpm.toStringAsFixed(1)}');
      }
    }

    setState(() => _isRecording = false);
    if (mounted) Navigator.pop(context);
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!stt.isConnected)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        '연결 중...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.shade100,
                    child: SingleChildScrollView(
                      child: Text(
                        stt.transcript,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              _isRecording
                                  ? Colors.black
                                  : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => stt.clearTranscript(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('초기화'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade600,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isRecording ? null : () => _start(stt),
                        icon: const Icon(Icons.mic),
                        label: const Text('녹음 시작'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isRecording ? () => _stop(stt) : null,
                        icon: const Icon(Icons.stop),
                        label: const Text('종료'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
