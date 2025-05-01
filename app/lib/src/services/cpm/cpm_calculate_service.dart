import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';

enum CpmStage { ready, timing, finished }

class CpmCalculateService extends ChangeNotifier {
  final List<String> _sentences = [
    '안녕하세요, 오늘 발표를 시작하겠습니다.',
    '이 프로젝트는 지난 몇 개월 동안 진행되었습니다.',
    '주요 목표는 사용자의 편의성을 높이는 것이었습니다.',
    '다음으로는 구현 과정에 대해 설명드리겠습니다.',
    '경청해 주셔서 감사합니다.',
  ];

  final _db = DatabaseService();
  final _auth = FirebaseAuth.instance;

  int _currentIndex = 0;
  DateTime? _startTime;
  double? _cpmResult;
  List<double> _cpmList = [];
  CpmStage _stage = CpmStage.ready;

  String get currentSentence => _sentences[_currentIndex];
  double? get cpmResult => _cpmResult;
  double? get averageCpm =>
      _cpmList.isEmpty
          ? null
          : _cpmList.reduce((a, b) => a + b) / _cpmList.length;
  String get buttonText {
    switch (_stage) {
      case CpmStage.ready:
        return '시작';
      case CpmStage.timing:
        return '종료';
      case CpmStage.finished:
        return isLast ? '완료' : '다음 문장';
    }
  }

  CpmStage get stage => _stage;
  bool get isLast => _currentIndex == _sentences.length - 1;

  void onButtonPressed(BuildContext context) async {
    switch (_stage) {
      case CpmStage.ready:
        _startTime = DateTime.now();
        _cpmResult = null;
        _stage = CpmStage.timing;
        break;

      case CpmStage.timing:
        final endTime = DateTime.now();
        final seconds = endTime.difference(_startTime!).inMilliseconds / 1000.0;
        final chars = currentSentence.length;
        final cpm = (chars / seconds) * 60;
        _cpmResult = cpm;
        _cpmList.add(cpm);
        _stage = CpmStage.finished;
        break;

      case CpmStage.finished:
        if (isLast) {
          final avg = averageCpm;
          final user = _auth.currentUser;
          if (user != null && avg != null) {
            await _db.updateDB("users/${user.uid}", {
              'cpm': avg,
              'updatedAt': DateTime.now().toIso8601String(),
            });
          }

          // 🔁 ProfilePage로 이동
          if (context.mounted) {
            Navigator.pop(context, averageCpm);
          }
        } else {
          _currentIndex++;
          _cpmResult = null;
          _stage = CpmStage.ready;
        }
        break;
    }

    notifyListeners();
  }
}
