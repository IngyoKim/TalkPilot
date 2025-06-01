import 'package:flutter/material.dart';

class PresentationHistoryPage extends StatelessWidget {
  const PresentationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('발표 기록 확인', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text(
          '발표 기록 확인 페이지는 현재 개발 중입니다.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
