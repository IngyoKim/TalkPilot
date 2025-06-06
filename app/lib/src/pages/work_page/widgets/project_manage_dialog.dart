import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/components/toast_message.dart';
import 'package:talk_pilot/src/provider/project_provider.dart';

// ignore_for_file: use_build_context_synchronously
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
