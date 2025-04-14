import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_pilot/src/services/auth/social_login.dart';

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

  /// 로그인 수행 (SocialLogin 객체를 받음)
  Future<void> login(SocialLogin loginProvider) async {
    try {
      final user = await loginProvider.login();
      if (user != null) {
        _user = user;
        _loginMethod = loginProvider;
        notifyListeners();
      } else {
        throw Exception("로그인 실패: 유저 정보가 null입니다.");
      }
    } catch (e) {
      debugPrint("[LoginProvider] 로그인 중 오류 발생: $e");
      rethrow;
    }
  }

  /// 로그아웃은 이전에 받은 provider로 수행
  Future<void> logout() async {
    try {
      await _loginMethod?.logout();
      await _auth.signOut();
    } finally {
      _user = null;
      _loginMethod = null;
      notifyListeners();
    }
  }
}
