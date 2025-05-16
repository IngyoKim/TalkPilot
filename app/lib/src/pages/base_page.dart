import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:talk_pilot/src/pages/login_page.dart';
import 'package:talk_pilot/src/components/bottom_bar.dart';
import 'package:talk_pilot/src/services/auth/server_auth_service.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoginPage();

          return FutureBuilder(
            future: serverLogin(), // Nest 서버 인증
            builder: (context, serverSnapshot) {
              if (serverSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (serverSnapshot.hasError) {
                debugPrint('Nest 서버 인증 실패: ${serverSnapshot.error}');
                return const LoginPage();
              }

              debugPrint('Nest 서버 인증 성공');
              return const BottomBar();
            },
          );
        },
      ),
    );
  }
}
