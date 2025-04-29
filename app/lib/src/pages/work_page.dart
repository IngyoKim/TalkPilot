import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/provider/project_provider.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/pages/project_detail_page.dart';
import 'package:talk_pilot/src/components/toast_message.dart';

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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'preparing':
        return const Color(0xFF4CAF50); // 초록
      case 'paused':
        return const Color(0xFFFFEB3B); // 노랑
      case 'completed':
        return const Color(0xFFF44336); // 빨강
      default:
        return Colors.grey; // 정의되지 않은 경우 회색
    }
  }

  void _showProjectDialog({ProjectModel? project}) {
    final isEditMode = project != null;
    final titleController = TextEditingController(text: project?.title ?? '');
    final descriptionController = TextEditingController(
      text: project?.description ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isEditMode ? '프로젝트 정보 수정' : '새 프로젝트 추가'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: '프로젝트 제목 입력'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: '프로젝트 설명 입력 (최대 30자)',
                    counterText: '',
                  ),
                  maxLength: 30,
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
                  final newTitle = titleController.text.trim();
                  final newDescription = descriptionController.text.trim();
                  if (newTitle.isEmpty) return;

                  if (isEditMode) {
                    final projectProvider = context.read<ProjectProvider>();
                    projectProvider.selectedProject = project;
                    await projectProvider.updateProject({
                      ProjectField.title: newTitle,
                      ProjectField.description: newDescription,
                    });
                    ToastMessage.show(
                      '프로젝트 정보가 수정되었습니다.',
                      backgroundColor: const Color.fromARGB(255, 170, 158, 52),
                    );
                  } else {
                    final user = context.read<UserProvider>().currentUser;
                    if (user != null) {
                      await context.read<ProjectProvider>().createProject(
                        title: newTitle,
                        description: newDescription,
                        currentUser: user,
                      );
                      ToastMessage.show(
                        '프로젝트가 추가되었습니다.',
                        backgroundColor: const Color(0xFF4CAF50),
                      );
                    }
                  }
                  Navigator.pop(context);
                },
                child: Text(isEditMode ? '수정 완료' : '추가'),
              ),
            ],
          ),
    );
  }

  void _showDeleteProjectDialog(ProjectModel project) {
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
                  await context.read<ProjectProvider>().deleteProject(
                    project.id,
                  );
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
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showProjectDialog(),
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
                              childAspectRatio: 2.5,
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
                                        const SizedBox(height: 4),
                                        Text(
                                          project.description.isNotEmpty
                                              ? project.description
                                              : '설명 없음',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '생성일: ${DateFormat('yyyy-MM-dd / hh:mm a').format(project.createdAt!)}',
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
                                    child: Row(
                                      children: [
                                        // 상태 변경 버튼 (색 원)
                                        PopupMenuButton<String>(
                                          onSelected: (value) async {
                                            context
                                                .read<ProjectProvider>()
                                                .selectedProject = project;
                                            await context
                                                .read<ProjectProvider>()
                                                .updateProject({
                                                  ProjectField.status: value,
                                                });
                                            ToastMessage.show(
                                              '프로젝트 상태가 변경되었습니다.',
                                              backgroundColor: const Color(
                                                0xFF4CAF50,
                                              ),
                                            );
                                          },
                                          itemBuilder:
                                              (context) => [
                                                PopupMenuItem(
                                                  value: 'preparing',
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: Color(
                                                                0xFF4CAF50,
                                                              ),
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      const Text('진행 중'),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 'paused',
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: Color(
                                                                0xFFFFEB3B,
                                                              ),
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      const Text('보류'),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 'completed',
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: Color(
                                                                0xFFF44336,
                                                              ),
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      const Text('끝'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            margin: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                project.status,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),

                                        // 점 세개 버튼 (수정/삭제)
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _showProjectDialog(
                                                project: project,
                                              );
                                            } else if (value == 'delete') {
                                              _showDeleteProjectDialog(project);
                                            }
                                          },
                                          itemBuilder:
                                              (context) => [
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Text('수정'),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Text('삭제'),
                                                ),
                                              ],
                                          icon: const Icon(Icons.more_vert),
                                        ),
                                      ],
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
