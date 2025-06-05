import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/user_model.dart';
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

class _ProjectActionDialog extends StatefulWidget {
  const _ProjectActionDialog();

  @override
  State<_ProjectActionDialog> createState() => _ProjectActionDialogState();
}

class _ProjectActionDialogState extends State<_ProjectActionDialog> {
  int currentIndex = 0;
  bool isProcessing = false;

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
    if (isProcessing) return;
    setState(() => isProcessing = true);

    final title = titleController.text.trim();
    final desc = descriptionController.text.trim();
    final user = context.read<UserProvider>().currentUser;

    if (user == null || title.isEmpty) {
      setState(() => isProcessing = false);
      return;
    }

    final projectProvider = context.read<ProjectProvider>();
    final newProject = await projectProvider.createProject(
      title: title,
      description: desc,
      currentUser: user,
    );

    final mergedProjectIds = {
      ...?user.projectIds,
      newProject.id: newProject.status,
    };

    await context.read<UserProvider>().updateUser({
      UserField.projectIds: mergedProjectIds,
    });

    ToastMessage.show(
      '프로젝트가 생성되었습니다.',
      backgroundColor: const Color(0xFF4CAF50),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
    setState(() => isProcessing = false);
  }

  Future<void> _handleJoin() async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    final inputId = projectIdController.text.trim();
    final user = context.read<UserProvider>().currentUser;

    if (inputId.isEmpty || user == null) {
      setState(() => isProcessing = false);
      return;
    }

    final projectService = ProjectService();
    final project = await projectService.readProject(inputId);

    if (project == null) {
      ToastMessage.show(
        '존재하지 않는 프로젝트입니다.',
        backgroundColor: const Color(0xFFF44336),
      );
      setState(() => isProcessing = false);
      return;
    }

    if (project.participants.containsKey(user.uid)) {
      ToastMessage.show(
        '이미 참여 중인 프로젝트입니다.',
        backgroundColor: const Color(0xFF9E9E9E),
      );
      if (!mounted) return;
      Navigator.pop(context);
      setState(() => isProcessing = false);
      return;
    }

    await projectService.updateProject(project.id, {
      'participants': {...project.participants, user.uid: 'member'},
    });

    await UserService().updateUser(user.uid, {
      'projectIds': {...?user.projectIds, project.id: project.status},
    });

    await context.read<ProjectProvider>().loadProjects(user.uid);

    ToastMessage.show(
      '프로젝트에 참여했습니다.',
      backgroundColor: const Color(0xFF2196F3),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
    setState(() => isProcessing = false);
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
            onPressed: (index) {
              if (!isProcessing) setState(() => currentIndex = index);
            },
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
          onPressed: isProcessing ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: isProcessing
              ? null
              : () => currentIndex == 0 ? _handleCreate() : _handleJoin(),
          child: Text(currentIndex == 0 ? '생성' : '참여'),
        ),
      ],
    );
  }
}
