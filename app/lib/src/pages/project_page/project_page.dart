import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/components/loading_indicator.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/services/database/project_stream_service.dart';

import 'package:talk_pilot/src/pages/project_page/widgets/practice_button.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/script_part_page.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/project_info_card.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/script_upload_button.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/editable/editable_text_editor.dart';
import 'package:talk_pilot/src/utils/project/estimated_time_service.dart';

class ProjectPage extends StatefulWidget {
  final String projectId;
  const ProjectPage({super.key, required this.projectId});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final _projectService = ProjectService();
  final _estimatedTimeService = EstimatedTimeService();
  bool isLoading = false;
  bool isScriptEditable = false;

  @override
  void initState() {
    super.initState();
    _estimatedTimeService.streamEstimatedTime(widget.projectId);
  }

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
              const SizedBox(height: 16),
              const Text(
                '키워드 (쉼표로 구분)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: (project.keywords ?? []).join(', '),
                maxLength: 300,
                enabled: isEditable,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                ),
                onFieldSubmitted: (text) async {
                  final keywords =
                      text
                          .split(',')
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty)
                          .toList();

                  await _projectService.updateProject(project.id, {
                    'keywords': keywords,
                  });
                },
              ),
              const SizedBox(height: 16),
              EditableTextEditor(
                projectId: project.id,
                field: ProjectField.memo,
                label: '메모',
                value: project.memo ?? '',
                maxLength: 1000,
                editable: isEditable,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const SizedBox(width: 12),
                  const Text(
                    '대본',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Expanded(child: Container()),
                  if (isEditable)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isScriptEditable = !isScriptEditable;
                        });
                      },
                      child: Text(isScriptEditable ? '편집 종료' : '편집 시작'),
                    ),
                  const SizedBox(width: 12),
                ],
              ),
              const SizedBox(height: 8),
              EditableTextEditor(
                projectId: project.id,
                field: ProjectField.script,
                label: '',
                value: project.script ?? '',
                maxLength: 3000,
                editable: isEditable && isScriptEditable,
                scriptParts: project.scriptParts ?? [],
              ),
              const SizedBox(height: 24),
              if (isEditable)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ScriptPartPage(projectId: project.id),
                      ),
                    );
                  },
                  child: const Text('대본 파트 할당하기'),
                ),
              const SizedBox(height: 24),
              PracticeButton(project: project),
            ],
          ),
        );
      },
    );
  }
}
