import 'package:flutter_test/flutter_test.dart';
import 'package:talk_pilot/src/utils/project/score_service.dart';

void main() {
  late ScoreService scoreService;

  setUp(() {
    scoreService = ScoreService();
  });

  test('calculateScore perfect conditions', () {
    final score = scoreService.calculateScore(
      scriptAccuracy: 1.0,
      averageCpmStatus: '적당함',
      properCpmDurationSeconds: 60,
      actualDuration: Duration(seconds: 60),
      expectedDuration: Duration(seconds: 60),
    );

    expect(score, equals(100));
  });

  test('calculateScore 느림 status and low accuracy', () {
    final score = scoreService.calculateScore(
      scriptAccuracy: 0.5,
      averageCpmStatus: '느림',
      properCpmDurationSeconds: 30,
      actualDuration: Duration(seconds: 60),
      expectedDuration: Duration(seconds: 100),
    );

    expect(score, closeTo(52.5, 0.01));
  });

  test('calculateScore 빠름 status', () {
    final score = scoreService.calculateScore(
      scriptAccuracy: 0.8,
      averageCpmStatus: '빠름',
      properCpmDurationSeconds: 45,
      actualDuration: Duration(seconds: 50),
      expectedDuration: Duration(seconds: 50),
    );

    expect(score, closeTo(83.5, 0.01));
  });

  test('calculateScore unknown CpmStatus', () {
    final score = scoreService.calculateScore(
      scriptAccuracy: 0.0,
      averageCpmStatus: '엉뚱한값',
      properCpmDurationSeconds: 10,
      actualDuration: Duration(seconds: 100),
      expectedDuration: Duration(seconds: 50),
    );

    expect(score, closeTo(22.5, 0.01));
  });
}
