import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String nickname = '닉네임';
  String realName = '홍길동';
  int presentationCount = 12;
  double averageScore = 87.5;
  int averageCPM = 220;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('프로필'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: () {
              // TODO: 사용자 정보 새로고침
              debugPrint('새로고침 실행');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '설정',
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer(); // 오른쪽 사이드바 열기
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          children: [
            const ListTile(
              title: Text(
                '설정',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                // TODO: About 페이지 이동
                debugPrint('About 페이지로 이동');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () {
                // TODO: Help 페이지 이동
                debugPrint('Help 페이지로 이동');
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('FAQ'),
              onTap: () {
                // TODO: FAQ 페이지 이동
                debugPrint('FAQ 페이지로 이동');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                // TODO: 로그아웃 기능 연결
                debugPrint('로그아웃 시도');
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 닉네임 & 수정 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '닉네임: $nickname',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 닉네임 수정 폼 표시
                  debugPrint('닉네임 수정 버튼 클릭');
                },
                child: const Text('수정'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 실명
          Text(
            '이름: $realName',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),

          // 발표 정보
          Text('완료한 발표 횟수: $presentationCount'),
          Text('평균 발표 점수: $averageScore'),
          Text('평균 CPM: $averageCPM'),
          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: () {
              // TODO: 발표 기록 보기
              debugPrint('발표 기록 보기 버튼 클릭');
            },
            child: const Text('발표 기록 보기'),
          ),
        ],
      ),
    );
  }
}