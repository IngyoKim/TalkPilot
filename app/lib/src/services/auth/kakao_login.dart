import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

import 'package:talk_pilot/src/services/auth/social_login.dart';
import 'package:talk_pilot/src/services/auth/server_auth_service.dart';
import 'package:talk_pilot/src/services/auth/custom_token_service.dart';

/// Kakao Login을 수행
class KakaoLogin implements SocialLogin {
  // Firebase 인증 객체
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Firebase 커스텀 토큰 생성에 필요한 클래스
  final CustomTokenService _customTokenService = CustomTokenService();
  @override
  Future<User?> login() async {
    try {
      /// Choose login method depending on KakaoTalk installation
      if (await kakao.isKakaoTalkInstalled()) {
        debugPrint("KakaoTalk is installed.");
        try {
          //KakaoTalk을 이용한 로그인
          await kakao.UserApi.instance.loginWithKakaoTalk();
          debugPrint("Successed to login with KakaoTalk.");
        } catch (error) {
          //카카오톡 로그인 실패
          debugPrint("Fail to login with KakaoTalk.\n$error");
        }
      } else {
        //KakaoTalk 미설치 확인
        debugPrint("KakaoTalk isn't installed.");
        try {
          //카카오 계정을 이용한 로그인
          await kakao.UserApi.instance.loginWithKakaoAccount();
          debugPrint("Successed to login with Kakao.");
        } catch (error) {
          //카카오 계정 로그인 실패
          debugPrint("Fail to login with Kakao.\n$error");
        }
      }

      /// Retrieve Kakao user information
      final user = await kakao.UserApi.instance.me();

      /// Request Firebase custom token creation
      final response = await _customTokenService.createCustomToken({
        'uid': user.id.toString(),
        'displayName': user.kakaoAccount?.profile?.nickname ?? '',
        'email': user.kakaoAccount?.email ?? '',
        'photoURL': user.kakaoAccount?.profile?.profileImageUrl ?? '',
      });
      //Firebase로부터 받은 json 응답에서 토큰 추출
      final tokenData = jsonDecode(response);
      final customToken = tokenData['token'] ?? '';

      if (customToken.isEmpty) {
        //커스텀 토큰 생성
        debugPrint("Failed to retrieve custom token.");
        return null;
      }

      /// Firebase login
      UserCredential userCredential = await _auth.signInWithCustomToken(
        customToken,
      );
      await _auth.currentUser?.reload(); //Firebase 인증 상태 갱신

      /// Nest server 인증
      try {
        await serverLogin(); // /me 요청
        debugPrint("[Nest] 서버 인증 성공");
      } catch (e) {
        debugPrint("[Nest] 서버 인증 실패: $e");
      }

      /// Update user information
      return userCredential.user;
    } catch (error) {
      //로그인 프로세스 중 오류 발생
      debugPrint("Kakao login failed. $error");
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // 카카오 계정 연결 해제
      debugPrint("Attempting to unlink Kakao account...");
      await kakao.UserApi.instance.unlink();
      debugPrint("Successfully unlinked Kakao account.");
    } catch (error) {
      // 카카오 계정 연결 해제 실패
      debugPrint("Failed to unlink Kakao account: $error");
    }

    try {
      // Firebase 로그아웃 처리
      debugPrint("Attempting to sign out from Firebase...");
      await _auth.signOut(); //Firebase 에서 로그아웃
      debugPrint("Successfully signed out from Firebase.");
    } catch (error) {
      //Firebase 로그아웃 실패
      debugPrint("Failed to sign out from Firebase: $error");
    }
  }
}
