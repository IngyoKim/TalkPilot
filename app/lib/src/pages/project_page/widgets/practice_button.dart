import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/pages/profile_page/cpm_calculate_page.dart';
import 'package:talk_pilot/src/pages/practice_page/presentation_practice_page.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';

class PracticeButton extends StatelessWidget {
  final ProjectModel project;

  const PracticeButton({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        final user = context.read<UserProvider>().currentUser;
        if (user == null) return;

        final userModel = await UserService().readUser(user.uid);
        final userCpm = userModel?.cpm;

        if (userCpm == null || userCpm == 0.0) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('CPM 정보가 없습니다'),
              content: const Text(
                '발표 연습을 시작하기 전에\nCPM을 먼저 측정해주세요.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CpmCalculatePage(),
                      ),
                    );
                  },
                  child: const Text('측정하러 가기'),
                ),
              ],
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PresentationPracticePage(projectId: project.id),
          ),
        );
      },
      child: const Text('발표 연습 시작'),
    );
  }
}
