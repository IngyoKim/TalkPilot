import 'package:flutter/material.dart';
import 'stats_row.dart';

class StatsCard extends StatelessWidget {
  final int presentationCount;
  final double averageScore;
  final int averageCPM;

  const StatsCard({
    super.key,
    required this.presentationCount,
    required this.averageScore,
    required this.averageCPM,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            StatRow(
              icon: Icons.check_circle,
              label: '완료한 발표 횟수',
              value: '$presentationCount',
            ),
            const Divider(),
            StatRow(
              icon: Icons.star,
              label: '평균 발표 점수',
              value: '$averageScore',
            ),
            const Divider(),
            StatRow(
              icon: Icons.speed,
              label: '평균 CPM',
              value: '$averageCPM',
            ),
          ],
        ),
      ),
    );
  }
}
