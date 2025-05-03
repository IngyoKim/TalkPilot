import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/provider/project_provider.dart';

import 'package:talk_pilot/src/pages/project_page/project_detail_page.dart';
import 'package:talk_pilot/src/pages/work_page/widgets/project_card.dart';
import 'package:talk_pilot/src/pages/work_page/widgets/project_action_dialog.dart';

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().currentUser;
    if (user != null) {
      context.read<ProjectProvider>().loadProjects(user.uid);
    }
  }

  void _openProjectDetail(ProjectModel project) {
    context.read<ProjectProvider>().selectedProject = project;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetailPage(projectId: project.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectProvider>().projects;
    final sortedProjects = [...projects]
      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로젝트', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.add),
              iconSize: 28,
              color: Colors.white,
              tooltip: '프로젝트 추가',
              onPressed: () => showProjectActionDialog(context),
            ),
          ),
        ],
      ),

      body:
          projects.isEmpty
              ? const Center(
                child: Text(
                  '등록된 프로젝트가 없습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: sortedProjects.length,
                itemBuilder: (context, index) {
                  final project = sortedProjects[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProjectCard(
                      project: project,
                      onTap: () => _openProjectDetail(project),
                    ),
                  );
                },
              ),
    );
  }
}
