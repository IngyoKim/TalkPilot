class CpmCalculator {
  Duration _speakingDuration = Duration.zero;
  DateTime? _lastSpeechTime;

  void reset() {
    _speakingDuration = Duration.zero;
    _lastSpeechTime = null;
  }

  void updateOnTranscriptChange() {
    final now = DateTime.now();

    if (_lastSpeechTime != null) {
      final gap = now.difference(_lastSpeechTime!);
      if (gap.inSeconds < 2) {
        _speakingDuration += gap;
      }
    }

    _lastSpeechTime = now;
  }

  double calculateCpm(String text) {
    final charCount = text.replaceAll(' ', '').length;
    final seconds = _speakingDuration.inSeconds;
    if (seconds == 0) return 0;
    return (charCount / seconds) * 60;
  }

  int get speakingSeconds => _speakingDuration.inSeconds;
}
