import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/pages/work_page/widgets/work_helpers.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  late final TextEditingController _memoController;
  late SharedPreferences _prefs;

  bool _hasEdited = false;
  bool _isInitialized = false;
  String _originalText = '';

  String get _memoKey => 'memo_${widget.project.title}';

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController();
    _initializeMemo();
    _setupMemoListener();
  }

  Future<void> _initializeMemo() async {
    _prefs = await SharedPreferences.getInstance();
    final savedText = _prefs.getString(_memoKey) ?? '';
    _originalText = savedText;
    _memoController.text = savedText;
    setState(() => _isInitialized = true);
  }

  void _setupMemoListener() {
    _memoController.addListener(() async {
      if (!_isInitialized) return;

      final currentText = _memoController.text;
      final hasChanged = currentText != _originalText;

      if (_hasEdited != hasChanged) {
        setState(() => _hasEdited = hasChanged);
      }

      _prefs.setString(_memoKey, currentText);

      final uid =
          Provider.of<UserProvider>(context, listen: false).currentUser?.uid;
      if (uid == null) return;

      await ProjectService().updateProject(widget.project.id, {
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }

  @override
  void dispose() {
    if (_hasEdited) {
      _prefs.setString(_memoKey, _memoController.text);
    }
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    return Scaffold(
      appBar: AppBar(
        title: Text(project.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      project.description ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: getStatusColor(project.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '⏱ 목표 발표 시간',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              project.estimatedTime != null
                  ? '${project.estimatedTime! ~/ 60}분 ${project.estimatedTime! % 60}초'
                  : '미정',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              '👥 참여자 수',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${project.participants.length}명',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              '📝 대본',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _memoController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: '내용을 작성하세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
