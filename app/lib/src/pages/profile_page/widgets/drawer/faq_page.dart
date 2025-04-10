import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('About', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: const Text(
          '자주 묻는 질문과 그에 대한 답변',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
