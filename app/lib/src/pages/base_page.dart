import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
            return !snapshot.hasData
                ? const Scaffold()
                : const Scaffold(); // 각각 login_page, work_page로 이동시켜야함함
          },
        ),
      ),
    );
  }
}
