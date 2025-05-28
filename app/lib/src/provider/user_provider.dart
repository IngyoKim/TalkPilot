import 'package:flutter/material.dart';
import 'package:talk_pilot/src/models/cpm_record_model.dart';

import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/services/database/cpm_history_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get hasUser => _currentUser != null;

  /// 유저정보 로드
  Future<void> loadUser(String uid) async {
    final user = await _userService.readUser(uid);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }

  /// 유저정보 새로고침
  Future<void> refreshUser() async {
    if (_currentUser == null) return;
    final latest = await _userService.readUser(_currentUser!.uid);
    if (latest != null) {
      _currentUser = latest;
      notifyListeners();
    }
  }

  /// 유저 업데이트
  Future<void> updateUser(Map<UserField, dynamic> updates) async {
    if (_currentUser == null) return;
    final updateMap = {
      for (final entry in updates.entries) entry.key.key: entry.value,
    };
    await _userService.updateUser(_currentUser!.uid, updateMap);
    await refreshUser(); // 업데이트한 정보로 갱신
  }

  /// 유저 삭제(로컬에서)
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  /// 아래 두개의 메서드는 cpm 계산과 관련된 메서드
  /// [cpm] 기록 추가 + 평균 갱신 + 유저 새로고침
  Future<void> addCpm(double cpm) async {
    if (_currentUser == null) return;

    final record = CpmRecordModel(cpm: cpm, timestamp: DateTime.now());

    await _userService.addCpmRecord(_currentUser!.uid, record);
    await _userService.updateAverageCpm(_currentUser!.uid);
    await refreshUser(); // 평균 갱신된 값으로 유저 리로드
  }

  /// [cpm] 기록 전체 불러오기
  Future<List<CpmRecordModel>> fetchCpmHistory() async {
    if (_currentUser == null) return [];
    return await _userService.getCpmHistory(_currentUser!.uid);
  }
}
