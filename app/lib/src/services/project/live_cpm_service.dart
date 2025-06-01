import 'dart:async';

class LiveCpmService {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int _totalCharacters = 0;
  double _userAverageCpm = 0.0;
  double _currentCpm = 0.0;

  Function(double cpm, String status)? _onCpmUpdate;

  void start({
    required double userAverageCpm,
    required Function(double cpm, String status) onCpmUpdate,
  }) {
    _userAverageCpm = userAverageCpm;
    _onCpmUpdate = onCpmUpdate;
    _totalCharacters = 0;
    _stopwatch.reset();
    _stopwatch.start();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final minutes = _stopwatch.elapsed.inSeconds / 60;
      if (minutes > 0.1) {
        final cpm = _totalCharacters / minutes;
        _currentCpm = cpm; // 저장
        final status = getCpmStatus(_userAverageCpm, cpm);
        _onCpmUpdate?.call(cpm, status);
      }
    });
  }

  void updateRecognizedText(String text) {
    _totalCharacters = text.replaceAll(' ', '').length;
  }

  void stop() {
    _stopwatch.stop();
    _timer?.cancel();
    _timer = null;
    _onCpmUpdate = null;
  }

  void reset() {
    stop();
    _totalCharacters = 0;
    _stopwatch.reset();
  }

  String getCpmStatus(double userCpm, double currentCpm) {
    if (currentCpm < userCpm * 0.7) return '느림';
    if (currentCpm > userCpm * 1.3) return '빠름';
    return '적당함';
  }

  double get currentCpm => _currentCpm;
}
