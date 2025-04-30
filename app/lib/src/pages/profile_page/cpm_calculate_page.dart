import 'package:flutter/material.dart';

class CpmCalculatePage extends StatelessWidget {
  const CpmCalculatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // ProfilePage와 같은 배경색
      appBar: AppBar(
        backgroundColor: Colors.deepPurple, // 동일한 AppBar 색상
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'CPM 계산',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: const Center(
        child: Text(
          '여기에 CPM 계산 기능이 들어갈 예정입니다.',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}
