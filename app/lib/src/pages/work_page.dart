import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:talk_pilot/src/pages/project.dart';
import 'package:talk_pilot/src/components/toast_message.dart';
import 'package:talk_pilot/src/pages/project_detail_page.dart';


class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  final List<Project> projects = [];

  void _showAddProjectDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('새 프로젝트 추가'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: '프로젝트 제목'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  final title = controller.text.trim();
                  if (title.isNotEmpty) {
                    setState(() {
                      projects.insert(
                        0,
                        Project(
                          title: title,
                          createdAt: DateTime.now(),
                          practiceCount: 0,
                        ),
                      );
                    });
                    ToastMessage.show("새 프로젝트를 추가했습니다.", backgroundColor: Colors.green);
                  }
                  Navigator.pop(context);
                },
                child: const Text('추가'),
              ),
            ],
          ),
    );
  }

  void _openProjectDetail(Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProjectDetailPage(project: project)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedProjects = [...projects]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로젝트', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => debugPrint('설정 클릭'),
          ),
        ],
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
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      '생성일: ${DateFormat('yyyy-MM-dd / hh:mm:ss a').format(project.createdAt)}',
                                    ),
                                    Text('연습 횟수: ${project.practiceCount}회'),
                                  ],
                                ),
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
