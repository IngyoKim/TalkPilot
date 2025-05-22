import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/components/toast_message.dart';

import 'package:talk_pilot/src/pages/profile_page/cpm_calculate_page.dart';
import 'package:talk_pilot/src/pages/profile_page/widgets/profile_card.dart';
import 'package:talk_pilot/src/pages/profile_page/widgets/profile_drawer.dart';

import 'presentation_history_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nicknameController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isEditingNickname = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userProvider = context.read<UserProvider>();
      userProvider.refreshUser();
    });
  }

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
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('프로필', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
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
                  await context.read<UserProvider>().updateUser({
                    UserField.nickname: value,
                  });
                  setState(() => isEditingNickname = false);
                  ToastMessage.show("닉네임이 변경되었습니다.");
                }
              },
            ),
            const SizedBox(height: 20),
            StatsSummaryCard(
              completedCount:
                  userModel?.projectIds?.values
                      .where((v) => v == 'Completed')
                      .length ??
                  0,
              averageScore: userModel?.averageScore ?? 0,
              averageCPM: userModel?.cpm?.round() ?? 0,
              targetScore: userModel?.targetScore ?? 0,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PresentationHistoryPage(),
                  ),
                );
              },
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CpmCalculatePage(),
                  ),
                );

                if (result != null && result is double) {
                  await context.read<UserProvider>().refreshUser();
                }
              },
              icon: const Icon(Icons.calculate, color: Colors.white),
              label: const Text(
                'CPM 계산 페이지',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
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

class StatsSummaryCard extends StatelessWidget {
  final int completedCount;
  final double averageScore;
  final int averageCPM;
  final double targetScore;

  const StatsSummaryCard({
    super.key,
    required this.completedCount,
    required this.averageScore,
    required this.averageCPM,
    required this.targetScore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          children: [
            SizedBox(
              height: 104,
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.check_circle,
                      value: '$completedCount',
                      label: '완료한 발표',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: double.infinity,
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.star,
                      value: averageScore.toStringAsFixed(1),
                      label: '평균 점수',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.only(right: 4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.only(left: 4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 104,
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.speed,
                      value: '$averageCPM',
                      label: '평균 CPM',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: double.infinity,
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.flag,
                      value: targetScore.toStringAsFixed(1),
                      label: '목표 점수',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 26, color: Colors.deepPurple), // 아이콘 키움
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
