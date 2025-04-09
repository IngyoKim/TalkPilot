import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_pilot/src/login/social_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

/// Kakao Login을 수행
class KakaoLogin implements SocialLogin {
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

      /// 이곳에 firebase auth와 연동 코드 추가 예정정

      return null; // 여기에 firebase auth를 통해 받은 유저 return 예정
    } catch (error) {
      //로그인 프로세스 중 오류 발생
      debugPrint("Kakao login failed. $error");
      return null;
    }
  }

  @override
  Future<void> logout() async {
    /// 카카오 로그아웃 구현 예정
  }
}
