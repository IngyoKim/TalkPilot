import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/provider/project_provider.dart';
import 'package:talk_pilot/src/components/toast_message.dart';

import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

void showProjectActionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const _ProjectActionDialog(),
  );
}

// ignore_for_file: use_build_context_synchronously
class _ProjectActionDialog extends StatefulWidget {
  const _ProjectActionDialog();

  @override
  State<_ProjectActionDialog> createState() => _ProjectActionDialogState();
}

class _ProjectActionDialogState extends State<_ProjectActionDialog> {
  int currentIndex = 0;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final projectIdController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    projectIdController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final title = titleController.text.trim();
    final desc = descriptionController.text.trim();
    final user = context.read<UserProvider>().currentUser;
    final projectProvider = context.read<ProjectProvider>();

    if (user == null || title.isEmpty) return;

    await projectProvider.createProject(
      title: title,
      description: desc,
      currentUser: user,
    );

    ToastMessage.show(
      '프로젝트가 생성되었습니다.',
      backgroundColor: const Color(0xFF4CAF50),
    );

    Navigator.pop(context);
  }

  Future<void> _handleJoin() async {
    final inputId = projectIdController.text.trim();
    final user = context.read<UserProvider>().currentUser;
    if (inputId.isEmpty || user == null) return;

    final projectService = ProjectService();
    final userService = UserService();
    final projectProvider = context.read<ProjectProvider>();

    final project = await projectService.readProject(inputId);

    /// 잘못된 [projectId] 처리
    if (project == null) {
      ToastMessage.show(
        '존재하지 않는 프로젝트입니다.',
        backgroundColor: const Color(0xFFF44336),
      );
      return;
    }

    /// 이미 참여중인 프로젝트 처리
    if (project.participants.containsKey(user.uid)) {
      ToastMessage.show(
        '이미 참여 중인 프로젝트입니다.',
        backgroundColor: const Color(0xFF9E9E9E),
      );
      Navigator.pop(context);
      return;
    }

    /// DB에 참여자 추가
    await projectService.updateProject(project.id, {
      'participants': {...project.participants, user.uid: 'Member'},
    });

    /// 유저 정보에 프로젝트 추가
    await userService.updateUser(user.uid, {
      'projectIds': {...?user.projectIds, project.id: project.status},
    });

    /// 전체 프로젝트 다시 로드
    await projectProvider.loadProjects(user.uid);

    ToastMessage.show(
      '프로젝트에 참여했습니다.',
      backgroundColor: const Color(0xFF2196F3),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('프로젝트'),
          ToggleButtons(
            isSelected: [currentIndex == 0, currentIndex == 1],
            onPressed: (index) => setState(() => currentIndex = index),
            constraints: const BoxConstraints(minWidth: 80),
            borderRadius: BorderRadius.circular(8),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('생성'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('참여'),
              ),
            ],
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentIndex == 0)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: '제목 입력'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: '설명 입력 (최대 100자)',
                    counterText: '',
                  ),
                  maxLength: 100,
                  minLines: 1,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                ),
              ],
            )
          else
            TextField(
              controller: projectIdController,
              decoration: const InputDecoration(hintText: '프로젝트 ID 입력'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => currentIndex == 0 ? _handleCreate() : _handleJoin(),
          child: Text(currentIndex == 0 ? '생성' : '참여'),
        ),
      ],
    );
  }
}
