import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';

import 'package:talk_pilot/src/components/toast_message.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/date_picker.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/time_editor.dart';

class ProjectInfoCard extends StatelessWidget {
  final ProjectModel project;
  final bool editable;

  const ProjectInfoCard({
    super.key,
    required this.project,
    this.editable = true,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '없음';
    return DateFormat('yyyy-MM-dd / HH:mm').format(date);
  }

  Widget _infoRow(String label, String value) {
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
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _copyableRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: SelectableText(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ToastMessage.show("프로젝트 ID가 복사되었습니다");
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.copy, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ownerNickname() {
    return FutureBuilder<UserModel?>(
      future: UserService().readUser(project.ownerUid),
      builder: (context, snapshot) {
        final nickname = snapshot.hasData ? snapshot.data!.nickname : '로딩 중...';
        return _infoRow('생성자', nickname);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _copyableRow('프로젝트 ID', project.id),
            const SizedBox(height: 12),
            _infoRow('생성일', _formatDate(project.createdAt)),
            _infoRow('수정일', _formatDate(project.updatedAt)),
            _ownerNickname(),
            _infoRow('참여자 수', '${project.participants.length}명'),
            _infoRow('상태', project.status),
            const SizedBox(height: 8),
            EstimatedTimeEditor(
              projectId: project.id,
              initialSeconds: project.estimatedTime,
              editable: editable,
            ),
            const SizedBox(height: 6),
            DatePicker(
              projectId: project.id,
              field: ProjectField.scheduledDate,
              label: '발표 날짜',
              initialValue: project.scheduledDate,
              editable: editable,
            ),
            const SizedBox(height: 6),
            _infoRow('점수', project.score?.toStringAsFixed(1) ?? '없음'),
          ],
        ),
      ),
    );
  }
}
