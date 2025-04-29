import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/pages/work_page/widgets/project_detail_page.dart';
import 'package:talk_pilot/src/pages/work_page/widgets/work_dialogs.dart';
import 'package:talk_pilot/src/pages/work_page/widgets/project_card.dart';

import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/provider/project_provider.dart';
import 'package:talk_pilot/src/models/project_model.dart';

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
      MaterialPageRoute(builder: (_) => ProjectDetailPage(project: project)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final projects = context.watch<ProjectProvider>().projects;
    final sortedProjects = [...projects]
      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로젝트', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => showProjectDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('프로젝트 추가'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                projects.isEmpty
                    ? const Center(child: Text('등록된 프로젝트가 없습니다.'))
                    : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        itemCount: sortedProjects.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: (screenWidth / screenHeight) * 3.5,
                        ),
                        itemBuilder: (context, index) {
                          final project = sortedProjects[index];
                          return ProjectCard(
                            project: project,
                            onTap: () => _openProjectDetail(project),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
