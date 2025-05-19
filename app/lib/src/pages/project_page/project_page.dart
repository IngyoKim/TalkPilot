import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/script_part_page.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/components/loading_indicator.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/services/database/project_stream_service.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/project_info_card.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/script_upload_button.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/editable/editable_text_editor.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/practice_button.dart';

class ProjectPage extends StatefulWidget {
  final String projectId;
  const ProjectPage({super.key, required this.projectId});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed:
                        isEditable
                            ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          ScriptPartPage(projectId: project.id),
                                ),
                              );
                            }
                            : null,
                    child: const Text('대본 파트 할당하기'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

              PracticeButton(project: project),
            ],
          ),
        );
      },
    );
  }
}
