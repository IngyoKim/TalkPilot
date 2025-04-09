import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Project {
  final String title;
  final DateTime createdAt;
  final int practiceCount;

  Project({
    required this.title,
    required this.createdAt,
    required this.practiceCount,
  });
}

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  List<Project> projects = [];

  void _showAddProjectDialog() {
    String title = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 대본 추가'),
        content: TextField(
          autofocus: true,
          onChanged: (value) {
            title = value;
          },
          decoration: const InputDecoration(hintText: '대본 제목'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (title.trim().isNotEmpty) {
                setState(() {
                  projects.insert(
                    0,
                    Project(
                      title: title.trim(),
                      createdAt: DateTime.now(),
                      practiceCount: 0,
                    ),
                  );
                });
              }
              Navigator.pop(context);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('워크페이지'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              debugPrint('설정 클릭');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddProjectDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('대본 추가'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: projects.isEmpty
                ? const Center(child: Text('등록된 대본이 없습니다.'))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      itemCount: projects.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 3 / 2,
                      ),
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return Card(
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
                                Text('생성일: ${DateFormat('yyyy-MM-dd').format(project.createdAt)}'),
                                Text('연습 횟수: ${project.practiceCount}회'),
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