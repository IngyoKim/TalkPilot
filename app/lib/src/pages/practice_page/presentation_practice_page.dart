import 'package:flutter/material.dart';
import 'package:talk_pilot/src/pages/practice_page/widgets/presentation_practice_controller.dart';
import 'package:talk_pilot/src/pages/practice_page/widgets/result_button.dart';

import 'package:talk_pilot/src/pages/practice_page/widgets/info_card.dart';
import 'package:talk_pilot/src/pages/practice_page/widgets/cpm_updater.dart';
import 'package:talk_pilot/src/utils/project/script_comparison_view.dart';

class PresentationPracticePage extends StatefulWidget {
  final String projectId;
  const PresentationPracticePage({super.key, required this.projectId});

  @override
  State<PresentationPracticePage> createState() =>
      _PresentationPracticePageState();
}

class _PresentationPracticePageState extends State<PresentationPracticePage> {
  late final PresentationPracticeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PresentationPracticeController(
      projectId: widget.projectId,
      onUpdate: () {
        if (mounted) setState(() {});
      },
    );
    _controller.initialize();
  }

  @override
  void dispose() {
    // dispose 작업은 WillPopScope에서 처리
    super.dispose();
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = (_controller.scriptProgress * 100).toStringAsFixed(
      1,
    );
    final current =
        (_controller.scriptChunks.length * _controller.scriptProgress).round();
    final total = _controller.scriptChunks.length;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        await _controller.dispose();
        return true;
      },
      child: Scaffold(
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _controller.isListening
                            ? Colors.grey
                            : Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed:
                      _controller.isListening
                          ? _controller.stopListening
                          : _controller.startListening,
                  child: Text(_controller.isListening ? '발표 중지' : '발표 시작'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InfoCard(title: '진행도', value: '$progressPercent%'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InfoCard(
                        title: '정확도',
                        value:
                            '${(_controller.scriptAccuracy * 100).toStringAsFixed(1)}%',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InfoCard(
                        title: '발표자',
                        value: _controller.currentSpeakerNickname ?? '-',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InfoCard(
                        title: '현재 속도',
                        value: _controller.cpmStatus,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: LinearProgressIndicator(
                          value: _controller.scriptProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.deepPurple,
                          ),
                          minHeight: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$current / $total • $progressPercent%',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${formatDuration(_controller.presentationDuration)} / ${formatDuration(_controller.expectedDuration)}',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            _controller.presentationDuration >
                                    _controller.expectedDuration
                                ? Colors.red
                                : Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: ScriptComparisonView(
                        scriptChunks: _controller.scriptChunks,
                        recognizedText:
                            _controller.savedText + _controller.recognizedText,
                        splitText: _controller.splitText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ResultButton(
                  progress: _controller.scriptProgress,
                  accuracy: _controller.scriptAccuracy,
                  actualCpm: _controller.currentCpm,
                  userCpm: _controller.userCpm,
                  cpmStatus: _controller.cpmStatus,
                  actualDuration: _controller.presentationDuration,
                  expectedDuration: _controller.expectedDuration,
                  speakerResults: _controller.speakerResults,
                ),
                CpmUpdater(
                  progress: _controller.scriptProgress,
                  currentCpm: _controller.currentCpm,
                  alreadyUpdated: _controller.hasUpdatedCpm,
                  onUpdated: () {
                    setState(() {
                      _controller.hasUpdatedCpm = true;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
