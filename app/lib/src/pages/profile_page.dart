import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_pilot/src/pages/profile_page/about_page.dart';
import 'package:talk_pilot/src/pages/profile_page/faq_page.dart';
import 'package:talk_pilot/src/pages/profile_page/help_page.dart';
import 'package:talk_pilot/src/pages/profile_page/widgets/profile_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String nickname = '테스트 닉네임';
  String realName = '테스트 이름';
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
      endDrawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          children: [
            const ListTile(
              title: Text(
                '설정',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('FAQ'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FaqPage()),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('로그아웃 확인'),
                    content: const Text('정말 로그아웃하시겠어요?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          FirebaseAuth.instance.signOut();
                        },
                        child: const Text(
                          '로그아웃',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (isEditingNickname) {
            setState(() {
              isEditingNickname = false;
              nickname = nicknameController.text;
            });
            FocusScope.of(context).unfocus();
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            /// 분리된 프로필 카드
            ProfileCard(
              nickname: nickname,
              realName: realName,
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
              onNicknameSubmit: (value) {
                setState(() {
                  nickname = value;
                  isEditingNickname = false;
                });
              },
            ),

            const SizedBox(height: 20),

            /// 🔹 통계 카드
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    StatRow(
                      icon: Icons.check_circle,
                      label: '완료한 발표 횟수',
                      value: '$presentationCount',
                    ),
                    const Divider(),
                    StatRow(
                      icon: Icons.star,
                      label: '평균 발표 점수',
                      value: '$averageScore',
                    ),
                    const Divider(),
                    StatRow(
                      icon: Icons.speed,
                      label: '평균 CPM',
                      value: '$averageCPM',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// 발표 기록 버튼
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

class StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const StatRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
