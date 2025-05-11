import 'package:flutter/material.dart';

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
    final double diffPercent = userCpm == 0 ? 0 : ((actualCpm - userCpm) / userCpm) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('발표 결과'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 최종 평가',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('🗣️ 대본 정확도: ${(scriptAccuracy * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text('💬 평균 말하기 속도: ${actualCpm.toStringAsFixed(1)} CPM'),
            Text('🎯 내 기준 속도: ${userCpm.toStringAsFixed(1)} CPM'),
            Text('📉 속도 차이: ${diffPercent.toStringAsFixed(1)}%'),
            Text('⏱️ 해석: $cpmStatus'),
            const SizedBox(height: 16),
            Text('🕒 발표 시간: ${actualDuration.inSeconds}초'),
            Text('📌 예상 시간: ${expectedDuration.inSeconds}초'),
          ],
        ),
      ),
    );
  }
}
