import 'package:flutter/material.dart';
import 'package:talk_pilot/src/pages/practice_page/widgets/result_summary.dart';
import 'package:talk_pilot/src/pages/work_page/work_page.dart';

class PresentationResultPage extends StatelessWidget {
  final double scriptAccuracy;
  final double actualCpm;
  final double userCpm;
  final String cpmStatus;
  final Duration actualDuration;
  final Duration expectedDuration;

  const PresentationResultPage({
    super.key,
    required this.scriptAccuracy,
    required this.actualCpm,
    required this.userCpm,
    required this.cpmStatus,
    required this.actualDuration,
    required this.expectedDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('최종 결과'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResultSummary(
                scriptAccuracy: scriptAccuracy,
                actualCpm: actualCpm,
                userCpm: userCpm,
                cpmStatus: cpmStatus,
                actualDuration: actualDuration,
                expectedDuration: expectedDuration,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WorkPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('메인 화면으로 이동'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
