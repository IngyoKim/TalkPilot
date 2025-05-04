import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/services/database/project_stream_service.dart';
import 'package:talk_pilot/src/services/text_extract/docx_extract_service.dart';
import 'package:talk_pilot/src/services/text_extract/txt_extract_service.dart';

import 'package:talk_pilot/src/pages/project_page/widgets/text_editor.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/project_info_card.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;
  const ProjectDetailPage({super.key, required this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final _projectService = ProjectService();
  String? extractedDocxText;
  String? extractedTxtText;
  bool isLoadingDocx = false;
  bool isLoadingTxt = false;

  Future<void> pickAndExtractDocxText() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final service = DocxExtractService();

      setState(() {
        isLoadingDocx = true;
        extractedDocxText = null;
      });

      final text = await service.extractTextFromDocx(file);

      setState(() {
        extractedDocxText = text;
        isLoadingDocx = false;
      });
    }
  }

  Future<void> pickAndExtractTxtText() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final service = TxtExtractService();

      setState(() {
        isLoadingTxt = true;
        extractedTxtText = null;
      });

      final text = await service.extractTextFromTxt(file);

      setState(() {
        extractedTxtText = text;
        isLoadingTxt = false;
      });
    }
  }

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
                onPressed: isLoadingDocx ? null : pickAndExtractDocxText,
                icon: const Icon(Icons.upload_file),
                tooltip: 'DOCX 업로드',
              ),
              IconButton(
                onPressed: isLoadingTxt ? null : pickAndExtractTxtText,
                icon: const Icon(Icons.note_add),
                tooltip: 'TXT 업로드',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isLoadingDocx || isLoadingTxt)
                const LinearProgressIndicator(),

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
              const SizedBox(height: 32),

              if (extractedDocxText != null)
                _buildExtractedSection('DOCX', extractedDocxText!),

              if (extractedTxtText != null)
                _buildExtractedSection('TXT', extractedTxtText!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExtractedSection(String fileType, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추출된 $fileType 텍스트',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.deepPurple.shade100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
