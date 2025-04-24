import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastMessage {
  /// Show a custom toast message
  static void show(
  String message, {
  ToastGravity gravity = ToastGravity.BOTTOM,
  Color backgroundColor = Colors.black,
  Color textColor = Colors.white,
  double fontSize = 14.0,
  Toast toastLength = Toast.LENGTH_SHORT,
}) {
  Fluttertoast.showToast(
    msg: message,
    gravity: gravity,
    toastLength: toastLength,
    backgroundColor: backgroundColor,
    textColor: textColor,
    fontSize: fontSize,
  );
}
  /// 로그인 성공 메시지
  static void showLoginSuccess() {
    show("로그인에 성공했습니다.");
  }

  /// 유저 정보 불러오기 성공 메시지
  static void showUserInfoLoaded() {
    show("유저 정보를 불러왔습니다.");
  }

  /// 로그인 실패 메시지
  static void showLoginFailed() {
    show("로그인에 실패했습니다.");
  }
}
