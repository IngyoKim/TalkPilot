import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 프로젝트 추가'),
        content: TextField(
          controller: _controller,
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
              final title = _controller.text.trim();
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
      MaterialPageRoute(
        builder: (_) => ProjectDetailPage(project: project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로젝트'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => debugPrint('설정 클릭'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
  padding: const EdgeInsets.all(16.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      ElevatedButton.icon(
        onPressed: _showAddProjectDialog,
        icon: const Icon(Icons.add),
        label: const Text('프로젝트 추가'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
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
      ? const Center(child: Text('등록된 프로젝트가 없습니다.'))
      : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            itemCount: projects.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, index) {
              final sortedProjects = projects.toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
                        Text('생성일: ${DateFormat('yyyy-MM-dd').format(project.createdAt)}'),
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
class ProjectDetailPage extends StatefulWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  late TextEditingController _memoController;
  late SharedPreferences _prefs;

  String get _memoKey => 'memo_${widget.project.title}';

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController();
    _loadSavedMemo();

    // 실시간 저장
    _memoController.addListener(() {
      _prefs.setString(_memoKey, _memoController.text);
    });
  }

  Future<void> _loadSavedMemo() async {
    _prefs = await SharedPreferences.getInstance();
    final savedText = _prefs.getString(_memoKey) ?? '';
    setState(() {
      _memoController.text = savedText;
    });
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    return Scaffold(
      appBar: AppBar(
        title: Text(project.title,style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _memoController,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: '내용을 작성하세요...',
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}