import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/components/loading_indicator.dart';
import 'package:talk_pilot/src/components/toast_message.dart';

import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/services/database/project_stream_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/project_info_card.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/script_upload_button.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/editable/editable_text_editor.dart';
import 'package:talk_pilot/src/pages/practice_page/presentation_practice_page.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;
  const ProjectDetailPage({super.key, required this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final _projectService = ProjectService();
  bool isLoading = false;

  ProjectRole getUserRole(ProjectModel project, String? uid) {
    final role = project.participants[uid] ?? 'member';
    return switch (role.toLowerCase()) {
      'owner' => ProjectRole.owner,
      'editor' => ProjectRole.editor,
      _ => ProjectRole.member,
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = context.read<UserProvider>().currentUser?.uid;

    return StreamBuilder<ProjectModel>(
      stream: _projectService.streamProject(widget.projectId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: LoadingIndicator(
              isFetching: true,
              message: '데이터를 불러오는 중입니다...',
            ),
          );
        }

        final project = snapshot.data!;
        final isEditable =
            getUserRole(project, currentUid) != ProjectRole.member;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              project.title,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.deepPurple,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              if (isEditable)
                ScriptUploadButton(
                  context: context,
                  isLoading: isLoading,
                  projectId: widget.projectId,
                  setLoading: (val) => setState(() => isLoading = val),
                  mounted: mounted,
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isLoading) const LinearProgressIndicator(),
              const Text(
                '프로젝트 정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ProjectInfoCard(project: project, editable: isEditable),
              const SizedBox(height: 32),
              ...[
                EditableTextEditor(
                  projectId: project.id,
                  field: ProjectField.title,
                  label: '제목',
                  value: project.title,
                  maxLength: 100,
                  editable: isEditable,
                ),
                EditableTextEditor(
                  projectId: project.id,
                  field: ProjectField.description,
                  label: '설명',
                  value: project.description,
                  maxLength: 300,
                  editable: isEditable,
                ),
                EditableTextEditor(
                  projectId: project.id,
                  field: ProjectField.memo,
                  label: '메모',
                  value: project.memo ?? '',
                  maxLength: 1000,
                  editable: isEditable,
                ),
                EditableTextEditor(
                  projectId: project.id,
                  field: ProjectField.script,
                  label: '대본',
                  value: project.script ?? '',
                  maxLength: 3000,
                  editable: isEditable,
                ),
              ].expand((widget) => [widget, const SizedBox(height: 16)]),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  final user = context.read<UserProvider>().currentUser;
                  if (user == null) return;

                  final userModel = await UserService().readUser(user.uid);
                  final userCpm = userModel?.cpm;

                  if (userCpm == 0 || userCpm == null) {
                    ToastMessage.show("CPM 측정을 먼저 완료해주세요.");
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              PresentationPracticePage(projectId: project.id),
                    ),
                  );
                },
                child: const Text('발표 연습 시작'),
              ),
            ],
          ),
        );
      },
    );
  }
}
