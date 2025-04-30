import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
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
