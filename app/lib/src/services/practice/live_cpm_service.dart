import 'dart:async';

class LiveCpmService {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int _totalCharacters = 0;

  Function(double cpm)? _onCpmUpdate;

  void start({required Function(double cpm) onCpmUpdate}) {
    _onCpmUpdate = onCpmUpdate;
    _totalCharacters = 0;
    _stopwatch.reset();
    _stopwatch.start();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final minutes = _stopwatch.elapsed.inSeconds / 60;
      if (minutes > 0) {
        final cpm = _totalCharacters / minutes;
        _onCpmUpdate?.call(cpm);
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
}
