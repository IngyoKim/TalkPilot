import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:talk_pilot/src/pages/login_page.dart';
import 'package:talk_pilot/src/components/bottom_bar.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(context.toString());
    return Scaffold(
      body: Center(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            /// 로그인 여부에 따라 login_page or bottom_bar로 이동
            return !snapshot.hasData ? const LoginPage() : const BottomBar();
          },
        ),
      ),
    );
  }
}
