import 'package:flutter/material.dart';
import 'package:talk_pilot/src/pages/practice_page/widgets/result_summary.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ResultSummary(
          scriptAccuracy: scriptAccuracy,
          actualCpm: actualCpm,
          userCpm: userCpm,
          cpmStatus: cpmStatus,
          actualDuration: actualDuration,
          expectedDuration: expectedDuration,
        ),
      ),
    );
  }
}
