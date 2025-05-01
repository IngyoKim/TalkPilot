import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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

  String getStatusLabel(String status) {
    switch (status) {
      case 'preparing':
        return '진행 중';
      case 'paused':
        return '보류';
      case 'completed':
        return '끝';
      default:
        return '알 수 없음';
    }
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(value ?? '없음', style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ProjectModel project) {
    final createdAtFormatted =
        project.createdAt != null
            ? DateFormat('yyyy-MM-dd / HH:mm').format(project.createdAt!)
            : '없음';
    final updatedAtFormatted =
        project.updatedAt != null
            ? DateFormat('yyyy-MM-dd / HH:mm').format(project.updatedAt!)
            : '없음';

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoRow('프로젝트 ID', project.id),
            _infoRow('설명', project.description),
            _infoRow('생성일', createdAtFormatted),
            _infoRow('수정일', updatedAtFormatted),
            _infoRow('생성자 UID', project.ownerUid),
            _infoRow('참여자 수', '${project.participants.length}명'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 120,
                    child: Text(
                      '상태',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 3, right: 8),
                    decoration: BoxDecoration(
                      color: getStatusColor(project.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    getStatusLabel(project.status),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            _infoRow(
              '예상 시간',
              project.estimatedTime != null
                  ? '${project.estimatedTime! ~/ 60}분 ${project.estimatedTime! % 60}초'
                  : '미정',
            ),
            _infoRow(
              '점수',
              project.score != null ? project.score!.toStringAsFixed(1) : '없음',
            ),
          ],
        ),
      ),
    );
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '프로젝트 정보',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(project),
          const SizedBox(height: 32),
          const Text(
            '대본 메모',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
