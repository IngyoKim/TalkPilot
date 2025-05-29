import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';

import 'package:talk_pilot/src/pages/project_page/widgets/read_only/info_row.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/read_only/copyable_row.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/participant_list_button.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/editable/editable_date_picker.dart';
import 'package:talk_pilot/src/pages/project_page/widgets/estimated_format.dart';

class ProjectInfoCard extends StatelessWidget {
  final ProjectModel project;
  final bool editable;

  const ProjectInfoCard({
    super.key,
    required this.project,
    this.editable = false,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '없음';
    return DateFormat('yyyy-MM-dd / HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CopyableRow(label: '프로젝트 ID', value: project.id),
            const SizedBox(height: 12),
            InfoRow(label: '생성일', value: _formatDate(project.createdAt)),
            InfoRow(label: '수정일', value: _formatDate(project.updatedAt)),
            FutureBuilder<UserModel?>(
              future: UserService().readUser(project.ownerUid),
              builder: (context, snapshot) {
                final nickname =
                    snapshot.hasData ? snapshot.data!.nickname : '로딩 중...';
                return InfoRow(label: '생성자', value: nickname);
              },
            ),
            ParticipantListButton(project: project),
            InfoRow(label: '상태', value: project.status),
            const SizedBox(height: 8),
            InfoRow(
              label: '예상 시간',
              value: formatEstimatedTime(project.estimatedTime?.toDouble()),
            ),
            const SizedBox(height: 6),
            EditableDatePicker(
              projectId: project.id,
              field: ProjectField.scheduledDate,
              initialValue: project.scheduledDate,
              editable: editable,
            ),
            const SizedBox(height: 6),
            InfoRow(
              label: '점수',
              value: project.score?.toStringAsFixed(1) ?? '없음',
            ),
          ],
        ),
      ),
    );
  }
}
