import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final String nickname = '닉네임';
  final String realName = '홍길동';
  final int presentationCount = 12;
  final double averageScore = 87.5;
  final int averageCPM = 220;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              debugPrint('🔄 새로고침');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 설정 눌렀을 때 동작은 Step3에서 구현
              debugPrint('⚙️ 설정 클릭');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('닉네임: $nickname', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('이름: $realName', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          Text('완료한 발표 횟수: $presentationCount'),
          Text('평균 발표 점수: $averageScore'),
          Text('평균 CPM: $averageCPM'),
        ],
      ),
    );
  }
}