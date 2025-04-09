import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('About', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: const Text(
          '다양한 도움말',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
