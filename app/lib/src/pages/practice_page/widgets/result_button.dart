import 'package:flutter/material.dart';
import 'package:talk_pilot/src/pages/practice_page/presentation_result_page.dart';

class ResultButton extends StatelessWidget {
  final double progress;
  final double accuracy;
  final String cpmStatus;
  final Duration actualDuration;
  final Duration expectedDuration;

  const ResultButton({
    super.key,
    required this.progress,
    required this.accuracy,
    required this.cpmStatus,
    required this.actualDuration,
    required this.expectedDuration,
  });

  @override
  Widget build(BuildContext context) {
    final bool isProgressEnough = progress >= 0.9;

    return ElevatedButton(
      onPressed: isProgressEnough
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PresentationResultPage(
                    scriptAccuracy: accuracy,
                    cpmStatus: cpmStatus,
                    actualDuration: actualDuration,
                    expectedDuration: expectedDuration,
                  ),
                ),
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isProgressEnough ? Colors.deepPurple : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text('결과 보러 가기'),
    );
  }
}
