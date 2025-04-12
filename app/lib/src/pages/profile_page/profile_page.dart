import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/pages/profile_page/widgets/profile_card.dart';
import 'package:talk_pilot/src/pages/profile_page/widgets/stats_card.dart';
import 'package:talk_pilot/src/pages/profile_page/widgets/profile_drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int presentationCount = 12;
  double averageScore = 87.5;
  int averageCPM = 220;
  bool isEditingNickname = false;

  final TextEditingController nicknameController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = context.watch<UserProvider>().currentUser;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('프로필', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: () {
              debugPrint('새로고침 실행');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '설정',
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: const ProfileDrawer(),
      body: GestureDetector(
        onTap: () {
          if (isEditingNickname) {
            setState(() {
              isEditingNickname = false;
            });
            FocusScope.of(context).unfocus();
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ProfileCard(
              nickname: userModel?.nickname ?? 'Guest',
              realName: userModel?.email ?? 'No Email',
              profileImageUrl: userModel?.photoUrl,
              isEditing: isEditingNickname,
              nicknameController: nicknameController,
              onToggleEdit: () {
                setState(() {
                  isEditingNickname = !isEditingNickname;
                  if (!isEditingNickname) {
                    FocusScope.of(context).unfocus();
                  }
                });
              },
              onNicknameSubmit: (value) async {
                if (userModel != null) {
                  final updated = userModel.copyWith(
                    nickname: value,
                    updatedAt: DateTime.now(),
                  );
                  await context.read<UserProvider>().updateUser(updated);
                  setState(() => isEditingNickname = false);
                }
              },
            ),
            const SizedBox(height: 20),
            StatsCard(
              presentationCount: presentationCount,
              averageScore: userModel?.averageScore ?? averageScore,
              averageCPM: averageCPM,
              targetScore: userModel?.targetScore ?? 90.0,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => debugPrint('발표 기록 보기 버튼 클릭'),
              icon: const Icon(Icons.history, color: Colors.white),
              label: const Text(
                '발표 기록 보기',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
