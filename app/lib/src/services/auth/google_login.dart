import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:talk_pilot/src/services/auth/social_login.dart';

class GoogleLogin implements SocialLogin {
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;
  final Future<void> Function()? _serverLogin;

  GoogleLogin({
    GoogleSignIn? googleSignIn,
    FirebaseAuth? firebaseAuth,
    Future<void> Function()? serverLogin,
  })  : _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _serverLogin = serverLogin ?? serverLogin;

  @override
  Future<User?> login() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint("Google login was cancelled by the user.");
        return null;
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception(
          "Google login failed: Missing access token or ID token",
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      debugPrint("Successed to login with Google.");

      try {
        await _serverLogin?.call();
        debugPrint("[Nest] 서버 인증 성공");
      } catch (error) {
        debugPrint("[Nest] 서버 인증 실패: $error");
      }

      return userCredential.user;
    } catch (error) {
      debugPrint("Google Sign-In Error: $error");
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      debugPrint("Attempting to sign out from Google...");
      await _googleSignIn.signOut();
      debugPrint("Successfully signed out from Google.");
    } catch (error) {
      debugPrint("Failed to sign out from Google: $error");
    }

    try {
      debugPrint("Attempting to sign out from Firebase...");
      await _firebaseAuth.signOut();
      debugPrint("Successfully signed out from Firebase.");
    } catch (error) {
      debugPrint("Failed to sign out from Firebase: $error");
    }
  }
}
