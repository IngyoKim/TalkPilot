import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<Map<String, dynamic>> serverLogin() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('로그인된 사용자가 없습니다.');

  final idToken = await user.getIdToken();
  final apiUrl = dotenv.env['NEST_SERVER_URL'];

  if (apiUrl == null || apiUrl.isEmpty) {
    throw Exception('NEST_SERVER_URL 환경변수가 설정되지 않았습니다.');
  }

  final res = await http.get(
    Uri.parse('$apiUrl/me'),
    headers: {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    },
  );

  if (res.statusCode != 200) {
    throw Exception('서버에서 사용자 정보 조회 실패: ${res.statusCode}');
  }

  final userData = jsonDecode(res.body);
  debugPrint('[Nest] 사용자 정보 수신 완료');
  debugPrint('UID: ${userData['uid']}');
  debugPrint('이름: ${userData['name']}');
  debugPrint('프로필: ${userData['picture']}');

  return userData;
}
