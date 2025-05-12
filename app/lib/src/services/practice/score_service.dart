import 'dart:math';

class ScoreService {
  double calculateScore({
    required double scriptAccuracy,
    required String averageCpmStatus,
    required double properCpmDurationSeconds,
    required Duration actualDuration,
    required Duration expectedDuration,
  }) {
    final accuracyScore = (scriptAccuracy * 20).clamp(0, 20);

    final double avgCpmScore = switch (averageCpmStatus) {
      '적당함' => 25.0,
      '느림' || '빠름' => 15.0,
      _ => 5.0,
    };

    final totalSec = actualDuration.inSeconds.toDouble();
    final ratio = (properCpmDurationSeconds / totalSec).clamp(0.0, 1.0);
    final consistencyScore = (ratio * 25).clamp(0, 25);

    final expectedSec = expectedDuration.inSeconds.toDouble();
    final lowerBound = expectedSec * 0.85;
    final upperBound = expectedSec * 1.15;

    final double timeScore = (totalSec >= lowerBound && totalSec <= upperBound)
        ? 30.0
        : 15.0;

    return (accuracyScore + avgCpmScore + consistencyScore + timeScore).clamp(0, 100);
  }
}
