import 'package:flutter/material.dart';

class PresentationPracticePage extends StatelessWidget {
  final String projectId;
  const PresentationPracticePage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('발표 연습'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: const Center(
        child: Text(
          '발표 연습 기능은 준비 중입니다.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
