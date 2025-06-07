import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

import 'package:talk_pilot/src/services/auth/social_login.dart';
import 'package:talk_pilot/src/services/auth/custom_token_service.dart';

class KakaoLogin implements SocialLogin {
  final FirebaseAuth _auth;
  final CustomTokenService _customTokenService;
  final Future<Map<String, dynamic>> Function()? _serverLogin;
  final kakao.UserApi _userApi;
  final Future<bool> Function() _isKakaoTalkInstalled;

  KakaoLogin({
    FirebaseAuth? auth,
    CustomTokenService? customTokenService,
    Future<Map<String, dynamic>> Function()? serverLoginFn,
    kakao.UserApi? userApi,
    Future<bool> Function()? isKakaoTalkInstalledFn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _customTokenService = customTokenService ?? CustomTokenService(),
        _serverLogin = serverLoginFn,
        _userApi = userApi ?? kakao.UserApi.instance,
        _isKakaoTalkInstalled = isKakaoTalkInstalledFn ?? kakao.isKakaoTalkInstalled;

  @override
  Future<User?> login() async {
    try {
      // 로그인 방식 선택
      if (await _isKakaoTalkInstalled()) {
        debugPrint("KakaoTalk is installed.");
        try {
          await _userApi.loginWithKakaoTalk();
          debugPrint("Succeeded to login with KakaoTalk.");
        } catch (error) {
          return null;
        }
      } else {
        debugPrint("KakaoTalk isn't installed.");
        try {
          await _userApi.loginWithKakaoAccount();
          debugPrint("Succeeded to login with Kakao.");
        } catch (error) {
          debugPrint("Failed to login with Kakao: $error");
          return null;
        }
      }

      // 사용자 정보 조회
      final kakaoUser = await _userApi.me();

      // 커스텀 토큰 생성 요청
      final response = await _customTokenService.createCustomToken({
        'uid': kakaoUser.id.toString(),
        'displayName': kakaoUser.kakaoAccount?.profile?.nickname ?? '',
        'email': kakaoUser.kakaoAccount?.email ?? '',
        'photoURL': kakaoUser.kakaoAccount?.profile?.profileImageUrl ?? '',
      });

      final tokenData = jsonDecode(response);
      final customToken = tokenData['token'] ?? '';

      if (customToken.isEmpty) {
        debugPrint("Failed to retrieve custom token.");
        return null;
      }

      // Firebase 인증
      final userCredential = await _auth.signInWithCustomToken(customToken);
      await _auth.currentUser?.reload();

      // 서버 인증
      if (_serverLogin != null) {
        try {
          await _serverLogin();
          debugPrint("[Nest] 서버 인증 성공");
        } catch (error) {
          debugPrint("[Nest] 서버 인증 실패: $error");
        }
      }

      return userCredential.user;
    } catch (error) {
      debugPrint("Kakao login failed: $error");
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      debugPrint("Attempting to unlink Kakao account...");
      await _userApi.unlink();
      debugPrint("Successfully unlinked Kakao account.");
    } catch (error) {
      debugPrint("Failed to unlink Kakao account: $error");
    }

    try {
      debugPrint("Attempting to sign out from Firebase...");
      await _auth.signOut();
      debugPrint("Successfully signed out from Firebase.");
    } catch (error) {
      debugPrint("Failed to sign out from Firebase: $error");
    }
  }
}
