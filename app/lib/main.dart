import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:talk_pilot/app.dart';
import 'package:talk_pilot/firebase_options.dart';

Future<void> main() async {
  /// Flutter core engine 초기화
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const App());
}

