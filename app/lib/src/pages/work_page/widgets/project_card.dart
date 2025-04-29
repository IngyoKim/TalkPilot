import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/pages/work_page/widgets/work_dialogs.dart';
import 'package:talk_pilot/src/pages/work_page/widgets/work_helpers.dart';

import 'package:talk_pilot/src/provider/project_provider.dart';
import 'package:talk_pilot/src/components/toast_message.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const ProjectCard({super.key, required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.description.isNotEmpty
                        ? project.description
                        : '설명 없음',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (project.updatedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      formatElapsedTime(project.updatedAt!),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '생성일: ${DateFormat('yyyy-MM-dd / hh:mm a').format(project.createdAt!)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '참여자 수: ${project.participants.length}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      context.read<ProjectProvider>().selectedProject = project;
                      await context.read<ProjectProvider>().updateProject({
                        ProjectField.status: value,
                      });
                      ToastMessage.show(
                        '프로젝트 상태가 변경되었습니다.',
                        backgroundColor: const Color(0xFF4CAF50),
                      );
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'preparing',
                            child: Text('진행 중'),
                          ),
                          const PopupMenuItem(
                            value: 'paused',
                            child: Text('보류'),
                          ),
                          const PopupMenuItem(
                            value: 'completed',
                            child: Text('끝'),
                          ),
                        ],
                    child: Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: getStatusColor(project.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        showProjectDialog(context, project: project);
                      } else if (value == 'delete') {
                        showDeleteProjectDialog(context, project);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('수정')),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('삭제'),
                          ),
                        ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
