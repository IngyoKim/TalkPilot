import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:talk_pilot/src/login/social_login.dart';

/// Google Login을 수행
class GoogleLogin implements SocialLogin {
  @override
  Future<User?> login() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
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

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      debugPrint("Successed to login with Google.");
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
      await GoogleSignIn().signOut();
      debugPrint("Successfully signed out from Google.");
    } catch (error) {
      debugPrint("Failed to sign out from Google: $error");
    }

    try {
      debugPrint("Attempting to sign out from Firebase...");
      await FirebaseAuth.instance.signOut();
      debugPrint("Successfully signed out from Firebase.");
    } catch (error) {
      debugPrint("Failed to sign out from Firebase: $error");
    }
  }
}
