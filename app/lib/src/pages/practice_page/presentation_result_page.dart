import 'package:flutter/material.dart';
import 'package:talk_pilot/src/services/practice/score_service.dart';

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
    final scoreService = ScoreService();
    final double properCpmDurationSeconds = actualDuration.inSeconds * 0.85;

    final double totalScore = scoreService.calculateScore(
      scriptAccuracy: scriptAccuracy,
      averageCpmStatus: cpmStatus,
      properCpmDurationSeconds: properCpmDurationSeconds,
      actualDuration: actualDuration,
      expectedDuration: expectedDuration,
    );

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '${totalScore.toStringAsFixed(1)}점',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),

            const SizedBox(height: 32),

            _buildResultCard(title: '대본 정확도', value: '${(scriptAccuracy * 100).toStringAsFixed(1)}%'),
            _buildResultCard(title: '평균 말하기 속도', value: '${actualCpm.toStringAsFixed(1)} CPM'),
            _buildResultCard(title: '내 기준 속도', value: '${userCpm.toStringAsFixed(1)} CPM'),
            _buildResultCard(title: '속도 차이', value: '${diffPercent.toStringAsFixed(1)}%'),
            _buildResultCard(title: '속도 해석', value: cpmStatus),
            _buildResultCard(title: '발표 시간', value: '${actualDuration.inSeconds}초'),
            _buildResultCard(title: '예상 시간', value: '${expectedDuration.inSeconds}초'),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard({required String title, required String value}) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
