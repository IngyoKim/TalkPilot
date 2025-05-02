import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/provider/project_provider.dart';
import 'package:talk_pilot/src/components/toast_message.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectModel project;
  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  late final TextEditingController _memoController = TextEditingController();
  late final TextEditingController _descController = TextEditingController(
    text: widget.project.description,
  );
  late final DatabaseReference _memoRef;
  Timer? _debounce;

  void _setupMemoSync() {
    // DB → TextField
    _memoRef.onValue.listen((event) {
      final newText = event.snapshot.value as String? ?? '';
      if (_memoController.text != newText) {
        _memoController.text = newText;
      }
    });

    // TextField → DB (debounce & 실질적 변경 시만)
    _memoController.addListener(() {
      final newText = _memoController.text;

      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), () async {
        final snapshot = await _memoRef.get();
        final currentValue = snapshot.value as String? ?? '';

        if (newText != currentValue) {
          await _memoRef.set(newText);
          await ProjectService().updateProject(widget.project.id, {
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _memoRef = FirebaseDatabase.instance.ref(
      'projects/${widget.project.id}/memo',
    );
    _setupMemoSync();
  }

  @override
  void dispose() {
    _memoController.dispose();
    _descController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _format(DateTime? date) =>
      date != null ? DateFormat('yyyy-MM-dd / HH:mm').format(date) : '없음';

  Widget _info(String label, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(content)),
        ],
      ),
    );
  }

  Widget _buildProjectInfo(ProjectModel p) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '프로젝트 ID',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        tooltip: 'ID 복사',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: p.id));
                          ToastMessage.show("프로젝트 ID가 복사되었습니다");
                        },
                      ),
                      Flexible(
                        child: SelectableText(
                          p.id,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 120,
                  child: Text(
                    '발표 설명',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextField(
                      controller: _descController,
                      minLines: 1,
                      maxLines: 10,
                      maxLength: 100,
                      decoration: InputDecoration(
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
                        context.read<ProjectProvider>().updateProject({
                          ProjectField.description: value,
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            _info('생성일', _format(p.createdAt)),
            _info('수정일', _format(p.updatedAt)),
            FutureBuilder(
              future: UserService().readUser(p.ownerUid),
              builder: (context, snapshot) {
                final nickname =
                    snapshot.hasData
                        ? (snapshot.data as UserModel).nickname
                        : '로딩 중...';
                return _info('생성자', nickname);
              },
            ),
            _info('참여자 수', '${p.participants.length}명'),
            _info('상태', p.status),
            _info(
              '예상 시간',
              p.estimatedTime != null
                  ? '${p.estimatedTime! ~/ 60}분 ${p.estimatedTime! % 60}초'
                  : '미정',
            ),
            _info('점수', p.score?.toStringAsFixed(1) ?? '없음'),
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
          minLines: 1,
          maxLines: 1000,
          maxLength: 1000,
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
