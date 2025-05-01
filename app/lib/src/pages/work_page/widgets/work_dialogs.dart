import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/pages/work_page/widgets/project_card.dart';
import 'package:talk_pilot/src/pages/work_page/widgets/work_helpers.dart';
import 'package:talk_pilot/src/provider/project_provider.dart';
import 'package:talk_pilot/src/components/toast_message.dart';

class ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const ProjectCard({super.key, required this.project, required this.onTap});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final project = widget.project;

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: getStatusColor(project.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      onSelected: (value) async {
                        if (!context.mounted) return;
                        context.read<ProjectProvider>().selectedProject =
                            project;
                        await context.read<ProjectProvider>().updateProject({
                          ProjectField.status: value,
                        });
                        ToastMessage.show('프로젝트 상태가 변경되었습니다.');
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'preparing',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 6),
                                  Text('진행 중'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'paused',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: Colors.yellow,
                                  ),
                                  SizedBox(width: 6),
                                  Text('보류'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'completed',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 6),
                                  Text('끝'),
                                ],
                              ),
                            ),
                          ],
                    ),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) async {
                        if (!context.mounted) return;

                        if (value == 'edit') {
                          showProjectDialog(context, project: project);
                        } else if (value == 'delete') {
                          showDeleteProjectDialog(context, project);
                        } else if (value == 'copy_id') {
                          await Clipboard.setData(
                            ClipboardData(text: project.id),
                          );
                          ToastMessage.show('프로젝트 ID가 복사되었습니다.');
                        }
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('수정'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('삭제'),
                            ),
                            const PopupMenuItem(
                              value: 'copy_id',
                              child: Text('ID 복사'),
                            ),
                          ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (project.updatedAt != null)
                      Text(
                        formatElapsedTime(project.updatedAt!),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        project.estimatedTime != null
                            ? '⏱ ${project.estimatedTime! ~/ 60}분 ${project.estimatedTime! % 60}초'
                            : '⏱ 미정',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '생성일: ${DateFormat('yyyy-MM-dd / hh:mm a').format(project.createdAt!)}',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  ' 만든 사람:  / 참여자 수: ${project.participants.length}', //Owner 추후 추가 예정
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
