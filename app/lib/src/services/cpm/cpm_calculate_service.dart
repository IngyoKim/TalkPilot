import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';

class CpmCalculateService extends ChangeNotifier {
  final String sentence = '본인의 발표 속도대로 문장을 읽어주세요.';
  DateTime? _startTime;
  double? _cpmResult;
  bool _isRunning = false;

  final _db = DatabaseService();
  final _auth = FirebaseAuth.instance;

  String get displayedSentence => sentence;
  double? get cpmResult => _cpmResult;
  bool get isRunning => _isRunning;

  void toggleTimer() async {
    if (!_isRunning) {
      _startTime = DateTime.now();
      _cpmResult = null;
      _isRunning = true;
    } else {
      final endTime = DateTime.now();
      final seconds = endTime.difference(_startTime!).inMilliseconds / 1000.0;
      final int charCount = sentence.length;
      _cpmResult = (charCount / seconds) * 60;
      _isRunning = false;

      notifyListeners();

      if (_cpmResult != null) {
        final user = _auth.currentUser;
        if (user != null) {
          final uid = user.uid;

          /// 유저 문서에 cpm 값만 업데이트
          await _db.updateDB("users/$uid", {
            'cpm': _cpmResult,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      }
    }

    notifyListeners();
  }
}
