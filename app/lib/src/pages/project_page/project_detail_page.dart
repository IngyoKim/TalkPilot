import 'package:flutter/material.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/services/database/project_stream_service.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/text_editor.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/project_info_card.dart';
import 'package:talk_pilot/src/services/text_extract/text_extract_service.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;
  const ProjectDetailPage({super.key, required this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final _projectService = ProjectService();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProjectModel>(
      stream: _projectService.streamProject(widget.projectId),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.upload_file),
                tooltip: 'DOCX 또는 TXT 업로드',
                onPressed: isLoading
                    ? null
                    : () => pickAndExtractScriptText(
                          projectId: widget.projectId,
                          setLoading: (val) =>
                              setState(() => isLoading = val),
                          showMessage: (msg) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg)),
                            );
                          },
                          confirmDialog: (title, content) async {
                            if (!mounted) return false;
                            return await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: Text(title),
                                content: Text(content),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(false),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(true),
                                    child: const Text('확인'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isLoading) const LinearProgressIndicator(),
              const Text('프로젝트 정보',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
