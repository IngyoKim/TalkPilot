import 'package:flutter/material.dart';
import 'package:talk_pilot/src/pages/practice_page/widgets/presentation_practice_controller.dart';
import 'package:talk_pilot/src/pages/practice_page/widgets/script_comparison_view.dart';
import 'package:talk_pilot/src/pages/practice_page/widgets/result_button.dart';
import 'package:talk_pilot/src/pages/practice_page/widgets/info_card.dart';
import 'package:talk_pilot/src/pages/practice_page/widgets/cpm_updater.dart';

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
      onUpdate: () => setState(() {}),
    );
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _controller.isListening
                      ? Colors.grey
                      : Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _controller.isListening
                    ? _controller.stopListening
                    : _controller.startListening,
                child: Text(
                    _controller.isListening ? '발표 중지' : '발표 시작'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InfoCard(title: '현재 속도', value: _controller.cpmStatus),
                  InfoCard(
                    title: '진행도',
                    value:
                        '${(_controller.scriptProgress * 100).toStringAsFixed(1)}%',
                  ),
                  InfoCard(
                    title: '정확도',
                    value:
                        '${(_controller.scriptAccuracy * 100).toStringAsFixed(1)}%',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: ScriptComparisonView(
                      scriptChunks: _controller.scriptChunks,
                      recognizedText: _controller.recognizedText,
                      isSimilar: _controller.isSimilar,
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
              ),

              CpmUpdater(
                progress: _controller.scriptProgress,
                currentCpm: _controller.currentCpm,
                alreadyUpdated: _controller.hasUpdatedCpm,
                onUpdated: () => setState(() {
                  _controller.hasUpdatedCpm = true;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
