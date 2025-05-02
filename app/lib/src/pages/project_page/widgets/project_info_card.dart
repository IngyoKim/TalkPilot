import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/models/project_model.dart';

import 'package:talk_pilot/src/components/toast_message.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/date_picker.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/time_editor.dart';

class ProjectInfoCard extends StatelessWidget {
  final ProjectModel project;
  const ProjectInfoCard({super.key, required this.project});

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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 120,
                    child: Text(
                      '프로젝트 ID',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: SelectableText(
                            project.id,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: project.id));
                            ToastMessage.show("프로젝트 ID가 복사되었습니다");
                          },
                          child: const Icon(Icons.copy, size: 18),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            _info('생성일', _format(project.createdAt)),
            _info('수정일', _format(project.updatedAt)),
            FutureBuilder(
              future: UserService().readUser(project.ownerUid),
              builder: (context, snapshot) {
                final nickname =
                    snapshot.hasData
                        ? (snapshot.data as UserModel).nickname
                        : '로딩 중...';
                return _info('생성자', nickname);
              },
            ),
            _info('참여자 수', '${project.participants.length}명'),
            _info('상태', project.status),
            EstimatedTimeEditor(
              projectId: project.id,
              initialSeconds: project.estimatedTime,
            ),
            DatePicker(
              projectId: project.id,
              field: ProjectField.scheduledDate,
              label: '발표 날짜',
              initialValue: project.scheduledDate,
            ),
            _info('점수', project.score?.toStringAsFixed(1) ?? '없음'),
          ],
        ),
      ),
    );
  }
}
