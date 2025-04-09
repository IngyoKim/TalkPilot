import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

import 'package:talk_pilot/app.dart';
import 'package:talk_pilot/firebase_options.dart';

Future<void> main() async {
  /// Flutter core engine 초기화
  WidgetsFlutterBinding.ensureInitialized();

  /// .env 파일 로드
  await dotenv.load(fileName: ".env");

  /// Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']);

  runApp(const App());
}
