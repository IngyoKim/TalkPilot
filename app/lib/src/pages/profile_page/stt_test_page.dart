import 'package:flutter/material.dart';
import 'package:talk_pilot/src/services/stt/stt_service.dart';

class SttTestPage extends StatefulWidget {
  const SttTestPage({super.key});

  @override
  State<SttTestPage> createState() => _SttTestPageState();
}

class _SttTestPageState extends State<SttTestPage> {
  final SttService _sttService = SttService();
  String _text = '';
  bool _isListening = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initStt();
  }

  void _initStt() async {
    await _sttService.init();
    setState(() {});
  }

  void _toggleListening() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    if (_sttService.isListening) {
      await _sttService.stopListening();

      await Future.delayed(const Duration(milliseconds: 100));

      setState(() {
        _isListening = false;
        _isProcessing = false;
      });
    } else {
      setState(() {
        _isListening = true;
        _isProcessing = false;
      });

      _sttService.startListening((resultText) {
        setState(() {
          _text = resultText;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          '임시 STT 테스트 페이지',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _toggleListening,
              icon: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
              ),
              label: Text(
                _isListening ? '중지' : '말하기 시작',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.deepPurpleAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _text.isEmpty
                        ? '여기에 인식된 텍스트가 표시됩니다.'
                        : _text,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
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
