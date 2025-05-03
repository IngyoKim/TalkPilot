import 'package:flutter/material.dart';

class TxtTextPage extends StatelessWidget {
  const TxtTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TXT 텍스트 추출', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: const Center(
        child: Text(
          '여기에 TXT 텍스트 추출 기능을 추가할 예정입니다.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
