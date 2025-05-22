import 'package:flutter/material.dart';
import 'package:talk_pilot/src/pages/profile_page/widgets/stats_item.dart';

class StatsSummaryCard extends StatelessWidget {
  final int completedCount;
  final double averageScore;
  final int averageCPM;
  final double targetScore;

  const StatsSummaryCard({
    super.key,
    required this.completedCount,
    required this.averageScore,
    required this.averageCPM,
    required this.targetScore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          children: [
            SizedBox(
              height: 104,
              child: Row(
                children: [
                  Expanded(
                    child: StatItem(
                      icon: Icons.check_circle,
                      value: '$completedCount',
                      label: '완료한 발표',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: double.infinity,
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: StatItem(
                      icon: Icons.star,
                      value: averageScore.toStringAsFixed(1),
                      label: '평균 점수',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.only(right: 4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.only(left: 4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 104,
              child: Row(
                children: [
                  Expanded(
                    child: StatItem(
                      icon: Icons.speed,
                      value: '$averageCPM',
                      label: '평균 CPM',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: double.infinity,
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: StatItem(
                      icon: Icons.flag,
                      value: targetScore.toStringAsFixed(1),
                      label: '목표 점수',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}