import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_pilot/src/pages/practice_page/widgets/speaker_cpm_result.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/services/project/score_service.dart';

class ResultSummary extends StatefulWidget {
  final double scriptAccuracy;
  final double actualCpm;
  final double userCpm;
  final String cpmStatus;
  final Duration actualDuration;
  final Duration expectedDuration;
  final List<SpeakerCpmResult> speakerResults;

  const ResultSummary({
    super.key,
    required this.scriptAccuracy,
    required this.actualCpm,
    required this.userCpm,
    required this.cpmStatus,
    required this.actualDuration,
    required this.expectedDuration,
    required this.speakerResults,
  });

  @override
  State<ResultSummary> createState() => _ResultSummaryState();
}

class _ResultSummaryState extends State<ResultSummary> {
  double targetScore = 90.0;
  bool isLoading = true;

  late final double totalScore;

  @override
  void initState() {
    super.initState();

    final scoreService = ScoreService();
    final properCpmDurationSeconds = widget.actualDuration.inSeconds * 0.85;
    totalScore = scoreService.calculateScore(
      scriptAccuracy: widget.scriptAccuracy,
      averageCpmStatus: widget.cpmStatus,
      properCpmDurationSeconds: properCpmDurationSeconds,
      actualDuration: widget.actualDuration,
      expectedDuration: widget.expectedDuration,
    );

    _loadUserTargetScore();
  }

  Future<void> _loadUserTargetScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userModel = await UserService().readUser(user.uid);
    if (userModel != null) {
      setState(() {
        targetScore = userModel.targetScore ?? 90.0;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
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
          const SizedBox(height: 16),
          Center(
            child: Text(
              totalScore >= targetScore ? '목표 점수를 넘었습니다.' : '목표 점수를 넘지 못했습니다.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color:
                    totalScore >= targetScore ? Colors.green : Colors.redAccent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '목표 점수: ${targetScore.toStringAsFixed(1)}점',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
          _buildResultCard(
            title: '대본 정확도',
            value: '${(widget.scriptAccuracy * 100).toStringAsFixed(1)}%',
          ),
          _buildResultCard(
            title: '발표 시간',
            value: '${widget.actualDuration.inSeconds}초',
          ),
          _buildResultCard(
            title: '예상 시간',
            value: '${widget.expectedDuration.inSeconds}초',
          ),

          const SizedBox(height: 32),
          if (widget.speakerResults.isNotEmpty)
            const Text(
              '발표자별 속도 분석',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          const SizedBox(height: 12),

          ...widget.speakerResults.map((speaker) {
            final diff =
                speaker.userCpm == 0
                    ? 0
                    : ((speaker.actualCpm - speaker.userCpm) /
                            speaker.userCpm) *
                        100;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 24, thickness: 1),
                _buildResultCard(title: '발표자', value: speaker.nickname),
                _buildResultCard(
                  title: '평균 CPM',
                  value: '${speaker.actualCpm.toStringAsFixed(1)} CPM',
                ),
                _buildResultCard(
                  title: '나의 CPM',
                  value: '${speaker.userCpm.toStringAsFixed(1)} CPM',
                ),
                _buildResultCard(
                  title: '속도 차이',
                  value: '${diff.toStringAsFixed(1)}%',
                ),
                _buildResultCard(title: '속도 해석', value: speaker.cpmStatus),
              ],
            );
          }),
        ],
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
