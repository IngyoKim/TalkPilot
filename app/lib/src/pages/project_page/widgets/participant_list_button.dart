import 'package:flutter/material.dart';

import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/models/project_model.dart';

import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class ParticipantListButton extends StatelessWidget {
  final ProjectModel project;
  final bool editable;

  const ParticipantListButton({
    super.key,
    required this.project,
    required this.editable,
  });
  void _showDialog(BuildContext context) async {
    final userService = UserService();
    final uids = project.participants.keys.toList();

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<UserModel?>>(
          future: Future.wait(uids.map(userService.readUser)),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const AlertDialog(
                title: Text('참여자 목록'),
                content: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final users = snapshot.data!;
            return AlertDialog(
              title: const Text('참여자 목록'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: uids.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final uid = uids[index];
                    final nickname = users[index]?.nickname ?? '(알 수 없음)';
                    final role = project.participants[uid] ?? 'member';
                    return ListTile(
                      title: Text(nickname),
                      subtitle:
                          editable
                              ? _buildDropdownRole(uid, role)
                              : Text('역할: $role'),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDropdownRole(String uid, String currentRole) {
    final roles = ['owner', 'editor', 'member'];
    final normalizedRole = currentRole.toLowerCase();

    return DropdownButton<String>(
      value: roles.contains(normalizedRole) ? normalizedRole : 'member',
      isExpanded: true,
      onChanged: (val) {
        if (val != null) {
          ProjectService().updateProject(project.id, {
            'participants/$uid': val,
          });
        }
      },
      items:
          roles.map((role) {
            return DropdownMenuItem(value: role, child: Text('역할: $role'));
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 120,
            child: Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                '참여자 수',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  '${project.participants.length}명',
                  style: const TextStyle(fontSize: 14),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  onPressed: () => _showDialog(context),
                  tooltip: '참여자 보기',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
