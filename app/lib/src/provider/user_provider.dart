import 'package:flutter/material.dart';

import 'package:talk_pilot/src/models/user_model.dart';
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
      notifyListeners();
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    _currentUser = updatedUser;
    await _userService.updateUser(updatedUser);
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
