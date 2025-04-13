import 'package:flutter/material.dart';
import 'package:talk_pilot/src/services/stt_test.dart';

class SttTestPage extends StatefulWidget {
  const SttTestPage({super.key});

  @override
  _SttTestPageState createState() => _SttTestPageState();
}

class _SttTestPageState extends State<SttTestPage> {
  final SttService _sttService = SttService();
  String _text = '말해보세요!';
  bool _isListening = false;

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
    if (_sttService.isListening) {
      await _sttService.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() => _isListening = true);
      await _sttService.startListening((resultText) {
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
            Text(
              _text,
              style: const TextStyle(fontSize: 24, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _toggleListening,
              icon: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white),
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
          ],
        ),
      ),
    );
  }
}
