import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:talk_pilot/src/provider/project_provider.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/components/toast_message.dart';

// ignore_for_file: use_build_context_synchronously

// 프로젝트 ID 복사
void copyProjectId(BuildContext context, ProjectModel project) async {
  await Clipboard.setData(ClipboardData(text: project.id));
  ToastMessage.show('프로젝트 ID가 복사되었습니다.');
}

// 프로젝트 추가/수정 다이얼로그 표시
void showProjectDialog(BuildContext context, {ProjectModel? project}) {
  final isEditMode = project != null;

  // 컨트롤러 초기화
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
              _buildTextField(titleController, '프로젝트 제목 입력', autofocus: true),
              const SizedBox(height: 12),
              _buildTextField(
                descriptionController,
                '프로젝트 설명 입력 (최대 100자)',
                maxLength: 100,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                estimatedTimeController,
                '목표 발표 시간 (초 단위)',
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
              onPressed:
                  () async => _handleProjectSave(
                    context,
                    isEditMode,
                    project,
                    titleController,
                    descriptionController,
                    estimatedTimeController,
                  ),
              child: Text(isEditMode ? '수정 완료' : '추가'),
            ),
          ],
        ),
  );
}

// 텍스트 필드 빌더
Widget _buildTextField(
  TextEditingController controller,
  String hint, {
  int? maxLength,
  int maxLines = 1,
  bool autofocus = false,
  TextInputType? keyboardType,
}) {
  return TextField(
    controller: controller,
    autofocus: autofocus,
    decoration: InputDecoration(hintText: hint, counterText: ''),
    maxLength: maxLength,
    minLines: 1,
    maxLines: maxLines,
    keyboardType: keyboardType ?? TextInputType.text,
  );
}

// 프로젝트 저장 로직 처리
Future<void> _handleProjectSave(
  BuildContext context,
  bool isEditMode,
  ProjectModel? project,
  TextEditingController titleController,
  TextEditingController descriptionController,
  TextEditingController estimatedTimeController,
) async {
  final newTitle = titleController.text.trim();
  final newDescription = descriptionController.text.trim();
  final newEstimatedTime = int.tryParse(estimatedTimeController.text.trim());

  if (newTitle.isEmpty) return;

  final projectProvider = context.read<ProjectProvider>();

  if (isEditMode) {
    await _updateExistingProject(
      projectProvider,
      project!,
      newTitle,
      newDescription,
      newEstimatedTime,
    );
  } else {
    await _createNewProject(
      context,
      projectProvider,
      newTitle,
      newDescription,
      newEstimatedTime,
    );
  }

  Navigator.pop(context);
}

// 기존 프로젝트 업데이트 처리
Future<void> _updateExistingProject(
  ProjectProvider provider,
  ProjectModel project,
  String title,
  String description,
  int? estimatedTime,
) async {
  provider.selectedProject = project;
  await provider.updateProject({
    ProjectField.title: title,
    ProjectField.description: description,
    if (estimatedTime != null && estimatedTime >= 0)
      ProjectField.estimatedTime: estimatedTime,
  });

  ToastMessage.show(
    '프로젝트 정보가 수정되었습니다.',
    backgroundColor: const Color.fromARGB(255, 170, 158, 52),
  );
}

// 신규 프로젝트 생성 처리
Future<void> _createNewProject(
  BuildContext context,
  ProjectProvider provider,
  String title,
  String description,
  int? estimatedTime,
) async {
  final user = context.read<UserProvider>().currentUser;
  if (user != null) {
    await provider.createProject(
      title: title,
      description: description,
      currentUser: user,
      estimatedTime: estimatedTime,
    );

    final createdProject = provider.selectedProject;
    if (createdProject != null && estimatedTime != null) {
      await provider.updateProject({ProjectField.estimatedTime: estimatedTime});
    }

    ToastMessage.show(
      '프로젝트가 추가되었습니다.',
      backgroundColor: const Color(0xFF4CAF50),
    );
  } else {
    // TODO: 사용자 정보가 없을 경우 처리
  }
}

// 프로젝트 삭제 다이얼로그
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
