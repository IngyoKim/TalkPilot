import 'package:firebase_auth/firebase_auth.dart';

abstract class SocialLogin {
  Future<User?> login();
  Future<void> logout();
}
