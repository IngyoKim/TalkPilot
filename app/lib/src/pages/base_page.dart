import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:talk_pilot/src/pages/login_page.dart';
import 'package:talk_pilot/src/components/bottom_bar.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  bool _isUserLoaded = false;

  @override
  void initState() {
    super.initState();
    _prepareUser();
  }

  Future<void> _prepareUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await context.read<UserProvider>().loadUser(user.uid);
      if (mounted) setState(() => _isUserLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final firebaseUser = snapshot.data;

          if (firebaseUser == null) return const LoginPage();
          if (!_isUserLoaded)
            return const Center(child: CircularProgressIndicator());
          return const BottomBar();
        },
      ),
    );
  }
}
