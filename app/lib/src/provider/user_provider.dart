import 'package:flutter/material.dart';

import 'package:talk_pilot/src/models/user_model.dart';
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
}
