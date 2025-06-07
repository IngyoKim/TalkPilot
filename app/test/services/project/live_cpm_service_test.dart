import 'package:flutter_test/flutter_test.dart';
import 'package:talk_pilot/src/utils/project/live_cpm_service.dart';
import 'package:fake_async/fake_async.dart';

class FakeStopwatch implements Stopwatch {
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;

  @override
  void start() => _isRunning = true;

  @override
  void stop() => _isRunning = false;

  @override
  void reset() {
    _elapsed = Duration.zero;
    _isRunning = false;
  }

  @override
  Duration get elapsed => _elapsed;

  void setElapsed(Duration duration) {
    _elapsed = duration;
  }

  @override
  bool get isRunning => _isRunning;

  @override
  int get elapsedMilliseconds => _elapsed.inMilliseconds;

  @override
  int get elapsedMicroseconds => _elapsed.inMicroseconds;

  @override
  int get elapsedTicks => _elapsed.inMicroseconds;

  @override
  int get frequency => Duration.microsecondsPerSecond;
}

void main() {
  late LiveCpmService liveCpmService;
  late FakeStopwatch fakeStopwatch;
  late List<double> cpmUpdates;
  late List<String> statusUpdates;

  setUp(() {
    fakeStopwatch = FakeStopwatch();
    liveCpmService = LiveCpmService(stopwatchFactory: () => fakeStopwatch);
    cpmUpdates = [];
    statusUpdates = [];
  });

  test('LiveCpmService calculates CPM correctly', () {
    fakeAsync((async) {
      liveCpmService.start(
        userAverageCpm: 200.0,
        onCpmUpdate: (cpm, status) {
          cpmUpdates.add(cpm);
          statusUpdates.add(status);
        },
      );

      liveCpmService.updateRecognizedText('Hello world');
      fakeStopwatch.setElapsed(const Duration(seconds: 10));

      async.elapse(const Duration(seconds: 1));

      expect(cpmUpdates.isNotEmpty, true);
      expect(cpmUpdates.last, greaterThan(0));
      expect(statusUpdates.last, anyOf(['느림', '빠름', '적당함']));

      liveCpmService.stop();

      final previousCount = cpmUpdates.length;

      liveCpmService.updateRecognizedText('New text after stop');
      async.elapse(const Duration(seconds: 1));

      expect(cpmUpdates.length, equals(previousCount));
    });
  });

  test('LiveCpmService reset works correctly', () {
    fakeAsync((async) {
      liveCpmService.start(
        userAverageCpm: 200.0,
        onCpmUpdate: (cpm, status) {
          cpmUpdates.add(cpm);
          statusUpdates.add(status);
        },
      );

      liveCpmService.updateRecognizedText('Some text');
      fakeStopwatch.setElapsed(const Duration(seconds: 10));

      async.elapse(const Duration(seconds: 1));

      expect(cpmUpdates.isNotEmpty, true);

      liveCpmService.reset();

      expect(liveCpmService.currentCpm, 0);

      liveCpmService.updateRecognizedText('Hello again');
      fakeStopwatch.setElapsed(const Duration(seconds: 20));
      async.elapse(const Duration(seconds: 1));

      expect(cpmUpdates.last, greaterThan(0));

      liveCpmService.stop();
    });
  });
  test('LiveCpmService returns 빠름 when CPM is high', () {
    fakeAsync((async) {
      liveCpmService.start(
        userAverageCpm: 200.0,
        onCpmUpdate: (cpm, status) {
          cpmUpdates.add(cpm);
          statusUpdates.add(status);
        },
      );

      // 빠름 나오게 글자 수 많고 setElapsed 충분히
      liveCpmService.updateRecognizedText('a' * 1000);
      fakeStopwatch.setElapsed(const Duration(seconds: 10)); // 충분히 큰 값

      async.elapse(const Duration(seconds: 1));

      expect(statusUpdates.isNotEmpty, true);
      expect(statusUpdates.last, equals('빠름'));

      liveCpmService.stop();
    });
  });
}
