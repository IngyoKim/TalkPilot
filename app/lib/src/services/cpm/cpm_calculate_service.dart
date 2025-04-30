import 'package:flutter/material.dart';

class CpmCalculateService extends ChangeNotifier {
  final String sentence = '본인의 발표 속도대로 문장을 읽어주세요.';
  DateTime? _startTime;
  double? _cpmResult;
  bool _isRunning = false;

  String get displayedSentence => sentence;
  double? get cpmResult => _cpmResult;
  bool get isRunning => _isRunning;

  void toggleTimer() {
    if (!_isRunning) {
      _startTime = DateTime.now();
      _cpmResult = null;
      _isRunning = true;
    } else {
      final endTime = DateTime.now();
      final seconds =
          endTime.difference(_startTime!).inMilliseconds / 1000.0;
      final int charCount = sentence.length;
      _cpmResult = (charCount / seconds) * 60;
      _isRunning = false;
    }
    notifyListeners();
  }
}
