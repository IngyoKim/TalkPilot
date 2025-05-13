import 'package:flutter/material.dart';
import 'package:talk_pilot/src/pages/practice_page/presentation_result_page.dart';

class ResultButton extends StatelessWidget {
  final double progress;
  final double accuracy;
  final double userCpm;
  final double actualCpm;
  final String cpmStatus;
  final Duration actualDuration;
  final Duration expectedDuration;

  const ResultButton({
    super.key,
    required this.progress,
    required this.accuracy,
    required this.userCpm,
    required this.actualCpm,
    required this.cpmStatus,
    required this.actualDuration,
    required this.expectedDuration,
  });

  @override
  Widget build(BuildContext context) {
    final bool isProgressEnough = progress >= 0.9;

    if (!isProgressEnough) return const SizedBox.shrink(); 

    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PresentationResultPage(
              scriptAccuracy: accuracy,
              actualCpm: actualCpm,
              userCpm: userCpm,
              cpmStatus: cpmStatus,
              actualDuration: actualDuration,
              expectedDuration: expectedDuration,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text('결과 보러 가기'),
    );
  }
}
