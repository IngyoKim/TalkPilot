import 'package:flutter/material.dart';

import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/components/toast_message.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get hasUser => _currentUser != null;

  Future<void> loadUser(String uid) async {
    final user = await _userService.readUser(uid);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (_currentUser == null) return;
    final latest = await _userService.readUser(_currentUser!.uid);
    if (latest != null) {
      _currentUser = latest;
      ToastMessage.show("유저 정보를 다시 불러옵니다.");
      notifyListeners();
    }
  }

  Future<void> updateUser(Map<UserField, dynamic> updates) async {
    if (_currentUser == null) return;
    final updateMap = {
      for (final entry in updates.entries) entry.key.key: entry.value,
    };
    await _userService.updateUser(_currentUser!.uid, updateMap);
    await refreshUser(); // 업데이트한 정보로 갱신
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
