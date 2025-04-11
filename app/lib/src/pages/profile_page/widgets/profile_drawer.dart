import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/provider/login_provider.dart';
import 'package:talk_pilot/src/pages/profile_page/widgets/drawer/about_page.dart';
import 'package:talk_pilot/src/pages/profile_page/widgets/drawer/faq_page.dart';
import 'package:talk_pilot/src/pages/profile_page/widgets/drawer/help_page.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('FAQ'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FaqPage()),
              );
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
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('로그아웃 확인'),
                      content: const Text('정말 로그아웃하시겠어요?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop(); // 먼저 다이얼로그 닫고
                            await context
                                .read<LoginProvider>()
                                .logout(); // 프로바이더 통해 로그아웃
                          },
                          child: Text('로그아웃'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}
