import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:talk_pilot/src/provider/project_provider.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/components/toast_message.dart';

// ignore_for_file: use_build_context_synchronously
void showProjectDialog(BuildContext context, {ProjectModel? project}) {
  final isEditMode = project != null;
  final titleController = TextEditingController(text: project?.title ?? '');
  final descriptionController = TextEditingController(
    text: project?.description ?? '',
  );
  final estimatedTimeController = TextEditingController(
    text: project?.estimatedTime?.toString() ?? '',
  );

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(isEditMode ? '프로젝트 정보 수정' : '새 프로젝트 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(hintText: '프로젝트 제목 입력'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: '프로젝트 설명 입력 (최대 100자)',
                  counterText: '',
                ),
                maxLength: 100,
                minLines: 1,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: estimatedTimeController,
                decoration: const InputDecoration(hintText: '목표 발표 시간 (초 단위)'),
                keyboardType: TextInputType.number,
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
                final newEstimatedTime = int.tryParse(
                  estimatedTimeController.text.trim(),
                );

                if (newTitle.isEmpty) return;

                if (isEditMode) {
                  final projectProvider = context.read<ProjectProvider>();
                  projectProvider.selectedProject = project;
                  await projectProvider.updateProject({
                    ProjectField.title: newTitle,
                    ProjectField.description: newDescription,
                    if (newEstimatedTime != null && newEstimatedTime > 0)
                      ProjectField.estimatedTime: newEstimatedTime,
                  });
                  ToastMessage.show(
                    '프로젝트 정보가 수정되었습니다.',
                    backgroundColor: const Color.fromARGB(255, 170, 158, 52),
                  );
                } else {
                  final user = context.read<UserProvider>().currentUser;
                  if (user != null) {
                    await context.read<ProjectProvider>().createProject(
                      title: newTitle,
                      description: newDescription,
                      currentUser: user,
                      estimatedTime: newEstimatedTime,
                    );
                    ToastMessage.show(
                      '프로젝트가 추가되었습니다.',
                      backgroundColor: const Color(0xFF4CAF50),
                    );
                  }
                }
                Navigator.pop(context);
              },
              child: Text(isEditMode ? '수정 완료' : '추가'),
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

void copyProjectId(BuildContext context, ProjectModel project) async {
  await Clipboard.setData(ClipboardData(text: project.id));
  ToastMessage.show('프로젝트 ID가 복사되었습니다.');
}
