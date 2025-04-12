import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_pilot/src/login/social_login.dart';

class LoginProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  SocialLogin? _loginMethod;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  LoginProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  /// 로그인 수행 (SocialLogin 객체를 받음음)
  Future<void> login(SocialLogin loginProvider) async {
    final user = await loginProvider.login();
    if (user != null) {
      _user = user;
      _loginMethod = loginProvider;
      notifyListeners();
    }
  }

  /// 로그아웃은 이전에 사용한 provider로 수행
  Future<void> logout() async {
    await _loginMethod?.logout();
    await _auth.signOut(); // safety
    _user = null;
    _loginMethod = null;
    notifyListeners();
  }
}
