import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/provider/project_provider.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/pages/project_detail_page.dart';

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

  void _showAddProjectDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('새 프로젝트 추가'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: '프로젝트 제목'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(hintText: '프로젝트 설명 (선택)'),
                  maxLines: 3,
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
                  final title = titleController.text.trim();
                  final description = descriptionController.text.trim();
                  final user = context.read<UserProvider>().currentUser;

                  Navigator.pop(context);

                  if (title.isNotEmpty && user != null) {
                    await context.read<ProjectProvider>().createProject(
                      title: title,
                      description: description,
                      currentUser: user,
                    );
                  }
                },
                child: const Text('추가'),
              ),
            ],
          ),
    );
  }

  void _showDeleteProjectDialog(ProjectModel project) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('프로젝트 삭제'),
            content: Text('"${project.title}" 프로젝트를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  await context.read<ProjectProvider>().deleteProject(
                    project.id,
                  );
                  Navigator.pop(context);
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
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
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _showAddProjectDialog,
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 3.5,
                            ),
                        itemBuilder: (context, index) {
                          final project = sortedProjects[index];
                          return GestureDetector(
                            onTap: () => _openProjectDetail(project),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          project.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '생성일: ${DateFormat('yyyy-MM-dd / hh:mm:ss a').format(project.createdAt!)}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          '참여자 수: ${project.participants.length}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          _showDeleteProjectDialog(project);
                                        }
                                      },
                                      itemBuilder:
                                          (context) => [
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text('삭제'),
                                            ),
                                          ],
                                      icon: const Icon(Icons.more_vert),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
