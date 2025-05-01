import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/provider/project_provider.dart';

import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/pages/work_page/widgets/work_helpers.dart';

// ignore_for_file: use_build_context_synchronously
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
  }

  Future<void> _initializeMemo() async {
    _prefs = await SharedPreferences.getInstance();
    final savedText = _prefs.getString(_memoKey) ?? '';
    _originalText = savedText;
    _memoController.text = savedText;
    _isInitialized = true;

    _memoController.addListener(_onMemoChanged);
  }

  void _onMemoChanged() async {
    if (!_isInitialized) return;

    final currentText = _memoController.text;
    final hasChanged = currentText != _originalText;

    if (_hasEdited != hasChanged) {
      setState(() => _hasEdited = hasChanged);
    }

    // 저장은 항상 반영
    await _prefs.setString(_memoKey, currentText);

    // Project의 updatedAt만 갱신
    final uid =
        Provider.of<UserProvider>(context, listen: false).currentUser?.uid;
    if (uid != null) {
      await ProjectService().updateProject(widget.project.id, {
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  @override
  void dispose() {
    _memoController.removeListener(_onMemoChanged);
    _memoController.dispose();
    super.dispose();
  }

  String _getStatusLabel(String status) {
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

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('yyyy-MM-dd / HH:mm').format(date) : '없음';
  }

  Widget _infoRow(String label, Widget child) {
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
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildProjectInfo(ProjectModel project) {
    final TextEditingController descriptionController = TextEditingController(
      text: project.description,
    );

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 프로젝트 ID: 복사 버튼 + 텍스트
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '프로젝트 ID',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        tooltip: 'ID 복사',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: project.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('프로젝트 ID가 복사되었습니다'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      Flexible(
                        child: SelectableText(
                          project.id,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 설명 수정 가능
            _infoRow(
              '설명',
              TextField(
                controller: descriptionController,

                minLines: 1,
                maxLines: 10,
                maxLength: 100,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                decoration: InputDecoration(
                  isDense: true,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  context
                      .read<ProjectProvider>()
                      .updateProject({ProjectField.description: value})
                      .then((_) {
                        context.read<ProjectProvider>().refreshProject();
                      });
                },
              ),
            ),

            _infoRow('생성일', Text(_formatDate(project.createdAt))),
            _infoRow('수정일', Text(_formatDate(project.updatedAt))),
            _infoRow('생성자 UID', Text(project.ownerUid)),
            _infoRow('참여자 수', Text('${project.participants.length}명')),
            _infoRow(
              '상태',
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: getStatusColor(project.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(_getStatusLabel(project.status)),
                ],
              ),
            ),
            _infoRow(
              '예상 시간',
              Text(
                project.estimatedTime != null
                    ? '${project.estimatedTime! ~/ 60}분 ${project.estimatedTime! % 60}초'
                    : '미정',
              ),
            ),
            _infoRow(
              '점수',
              Text(
                project.score != null
                    ? project.score!.toStringAsFixed(1)
                    : '없음',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          _buildProjectInfo(project),
          const SizedBox(height: 32),
          _buildMemoEditor(),
        ],
      ),
    );
  }
}
