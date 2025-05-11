import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_pilot/src/services/stt/stt_service.dart';
import 'package:talk_pilot/src/services/practice/live_cpm_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/services/practice/script_progress_service.dart';

class PresentationPracticePage extends StatefulWidget {
  final String projectId;
  const PresentationPracticePage({super.key, required this.projectId});

  @override
  State<PresentationPracticePage> createState() => _PresentationPracticePageState();
}

class _PresentationPracticePageState extends State<PresentationPracticePage> {
  final SttService _sttService = SttService();
  final LiveCpmService _cpmService = LiveCpmService();
  final ScriptProgressService _progressService = ScriptProgressService();

  String _recognizedText = '';
  bool _isListening = false;
  double _currentCpm = 0.0;
  String _cpmStatus = '';
  double _userCpm = 0.0;
  double _scriptProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _sttService.init();
    _loadUserCpm();
    _loadScript();
  }

  void _loadUserCpm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userModel = await UserService().readUser(user.uid);
    if (userModel == null) return;

    setState(() {
      _userCpm = userModel.cpm ?? 200.0;
    });
  }

  void _loadScript() async {
    await _progressService.loadScript(widget.projectId);
    setState(() {});
  }

  void _startListening() {
    _cpmService.start(
      userAverageCpm: _userCpm,
      onCpmUpdate: (cpm, status) {
        if (!mounted) return;
        setState(() {
          _currentCpm = cpm;
          _cpmStatus = status;
        });
      },
    );

    _sttService.startListening((text) {
      if (!mounted) return;
      final progress = _progressService.calculateProgressByLastMatch(text);
      setState(() {
        _recognizedText = text;
        _isListening = true;
        _scriptProgress = progress;
      });
      _cpmService.updateRecognizedText(text);
    });
  }

  void _stopListening() async {
    await _sttService.stopListening();
    _cpmService.stop();
    if (!mounted) return;
    setState(() {
      _isListening = false;
    });
  }

  Widget _buildScriptComparisonView() {
    final scriptChunks = _progressService.scriptChunks;
    final recognizedWords = _progressService.splitText(_recognizedText);

    List<InlineSpan> scriptSpans = [];
    List<InlineSpan> recognizedSpans = [];

    for (final scriptWord in scriptChunks) {
      final isMatched = recognizedWords.any(
        (w) => _progressService.isSimilar(scriptWord, w),
      );

      scriptSpans.add(TextSpan(
        text: '$scriptWord ',
        style: TextStyle(
          fontSize: 16,
          fontWeight: isMatched ? FontWeight.bold : FontWeight.normal,
          color: isMatched ? Colors.deepPurple : Colors.black,
        ),
      ));
    }

    for (final word in recognizedWords) {
      recognizedSpans.add(TextSpan(
        text: '$word ',
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(text: TextSpan(children: scriptSpans)),
        const SizedBox(height: 4),
        RichText(text: TextSpan(children: recognizedSpans)),
      ],
    );
  }

  @override
  void dispose() {
    _sttService.stopListening();
    _cpmService.stop();
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
            const SizedBox(height: 16),
            Text(
              '현재 CPM: ${_currentCpm.toStringAsFixed(1)} ($_cpmStatus)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '진행도: ${(_scriptProgress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            const Text(
              '대본 및 인식 결과:',
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
                  child: _buildScriptComparisonView(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
