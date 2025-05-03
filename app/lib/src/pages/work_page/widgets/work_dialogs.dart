import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/components/toast_message.dart';

import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/provider/project_provider.dart';

// ignore_for_file: use_build_context_synchronously
void showProjectActionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const _ProjectActionDialog(),
  );
}

class _ProjectActionDialog extends StatefulWidget {
  const _ProjectActionDialog();

  @override
  State<_ProjectActionDialog> createState() => _ProjectActionDialogState();
}

class _ProjectActionDialogState extends State<_ProjectActionDialog> {
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
    ToastMessage.show(
      '프로젝트에 참여했습니다.',
      backgroundColor: const Color(0xFF2196F3),
    );

    Navigator.pop(context);
  }

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

/// 프로젝트 수정
void showEditProjectDialog(BuildContext context, ProjectModel project) {
  final titleController = TextEditingController(text: project.title);
  final descriptionController = TextEditingController(
    text: project.description,
  );

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('프로젝트 정보 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(hintText: '프로젝트 제목 수정'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: '프로젝트 설명 수정',
                  counterText: '',
                ),
                maxLength: 100,
                minLines: 1,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                final newTitle = titleController.text.trim();
                final newDescription = descriptionController.text.trim();
                if (newTitle.isEmpty) return;

                final projectProvider = context.read<ProjectProvider>();
                projectProvider.selectedProject = project;

                await projectProvider.updateProject({
                  ProjectField.title: newTitle,
                  ProjectField.description: newDescription,
                });

                ToastMessage.show(
                  '프로젝트 정보가 수정되었습니다.',
                  backgroundColor: const Color.fromARGB(255, 170, 158, 52),
                );
                Navigator.pop(context);
              },
              child: const Text('수정'),
            ),
          ],
        ),
  );
}

/// 프로젝트 삭제
void showDeleteProjectDialog(BuildContext context, ProjectModel project) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => AlertDialog(
          title: const Text('프로젝트 삭제'),
          content: Text('"${project.title}" 프로젝트를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('아니요'),
            ),
            TextButton(
              onPressed: () async {
                await context.read<ProjectProvider>().deleteProject(project.id);
                Navigator.pop(context);
                ToastMessage.show(
                  '프로젝트가 삭제되었습니다.',
                  backgroundColor: const Color(0xFFF44336),
                );
              },
              child: const Text('예', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
  );
}
