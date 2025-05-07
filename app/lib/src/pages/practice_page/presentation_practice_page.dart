import 'package:flutter/material.dart';
import 'package:talk_pilot/src/services/stt/stt_service.dart';

class PresentationPracticePage extends StatefulWidget {
  final String projectId;
  const PresentationPracticePage({super.key, required this.projectId});

  @override
  State<PresentationPracticePage> createState() => _PresentationPracticePageState();
}

class _PresentationPracticePageState extends State<PresentationPracticePage> {
  final SttService _sttService = SttService();
  String _recognizedText = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _sttService.init();
  }

  void _startListening() {
    _sttService.startListening((text) {
      if (!mounted) return;
      setState(() {
        _recognizedText = text;
        _isListening = true;
      });
    });
  }

  void _stopListening() async {
    await _sttService.stopListening();
    if (!mounted) return;
    setState(() {
      _isListening = false;
    });
  }

  @override
  void dispose() {
    _sttService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('발표 연습'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening ? Colors.grey : Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? '발표 중지' : '발표 시작'),
            ),
            const SizedBox(height: 24),
            const Text(
              '인식된 내용:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _recognizedText.isEmpty
                        ? '아직 인식된 내용이 없습니다.'
                        : _recognizedText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
