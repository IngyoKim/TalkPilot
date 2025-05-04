import 'package:flutter/material.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/services/database/project_stream_service.dart';

import 'package:talk_pilot/src/pages/project_page/widgets/text_editor.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/project_info_card.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;
  const ProjectDetailPage({super.key, required this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProjectModel>(
      stream: ProjectService().streamProject(widget.projectId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final project = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              project.title,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.deepPurple,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                '프로젝트 정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ProjectInfoCard(project: project),
              const SizedBox(height: 32),

              TextEditor(
                projectId: project.id,
                field: ProjectField.title,
                label: '제목',
                value: project.title,
                maxLength: 100,
              ),
              const SizedBox(height: 16),

              TextEditor(
                projectId: project.id,
                field: ProjectField.description,
                label: '설명',
                value: project.description,
                maxLength: 300,
              ),
              const SizedBox(height: 16),

              TextEditor(
                projectId: project.id,
                field: ProjectField.memo,
                label: '메모',
                value: project.memo ?? '',
                maxLength: 1000,
              ),
              const SizedBox(height: 16),

              TextEditor(
                projectId: project.id,
                field: ProjectField.script,
                label: '대본',
                value: project.script ?? '',
                maxLength: 3000,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
