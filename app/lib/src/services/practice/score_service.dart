import 'dart:math';

class ScoreService {
  double calculateScore({
    required double scriptAccuracy, 
    required String cpmStatus,   
    required Duration actualDuration,
    required Duration expectedDuration,
  }) {
    final scriptScore = (scriptAccuracy * 50).clamp(0, 50);

    double speedScore = switch (cpmStatus) {
      '적당함' => 25,
      '느림' || '빠름' => 15,
      _ => 0,
    };

    final lowerBound = expectedDuration.inSeconds * 0.85;
    final upperBound = expectedDuration.inSeconds * 1.15;
    final actualSec = actualDuration.inSeconds;

    final timeScore = (actualSec >= lowerBound && actualSec <= upperBound) ? 25 : 15;

    return min(scriptScore + speedScore + timeScore, 100);
  }

  String getGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
}
