import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('About', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: const Text(
          '발표 도우미 프로그램',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
