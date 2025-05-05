import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/models/project_model.dart';

import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class ParticipantListButton extends StatefulWidget {
  final ProjectModel project;
  const ParticipantListButton({super.key, required this.project});

  @override
  State<ParticipantListButton> createState() => _ParticipantListButtonState();
}

class _ParticipantListButtonState extends State<ParticipantListButton> {
  static const List<String> allRoles = ['member', 'editor', 'owner'];

  void _showDialog(BuildContext context) async {
    final currentUid = context.read<UserProvider>().currentUser?.uid;
    final userService = UserService();
    final uids = widget.project.participants.keys.toList();

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
            Map<String, String> roles = Map.from(widget.project.participants);

            return StatefulBuilder(
              builder: (context, setStateDialog) {
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
                        final currentRole =
                            roles[uid]?.toLowerCase() ?? 'member';
                        final currentUserRole =
                            roles[currentUid]?.toLowerCase() ?? 'member';
                        final isSelf = uid == currentUid;

                        final roleOptions = getRoleOptions(
                          currentUserRole,
                          currentRole,
                          isSelf,
                        );
                        final isDropdownEnabled = roleOptions.isNotEmpty;

                        return _buildParticipantTile(
                          nickname: nickname,
                          uid: uid,
                          currentRole: currentRole,
                          isDropdownEnabled: isDropdownEnabled,
                          roleOptions: roleOptions,
                          roles: roles,
                          setStateDialog: setStateDialog,
                          currentUid: currentUid!,
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
      },
    );
  }

  List<String> getRoleOptions(
    String currentUserRole,
    String targetRole,
    bool isSelf,
  ) {
    if (currentUserRole == 'owner' && !isSelf) {
      return allRoles;
    } else if (currentUserRole == 'editor' && targetRole == 'member') {
      return ['member', 'editor'];
    }
    return [];
  }

  Widget _buildParticipantTile({
    required String nickname,
    required String uid,
    required String currentRole,
    required bool isDropdownEnabled,
    required List<String> roleOptions,
    required Map<String, String> roles,
    required void Function(VoidCallback) setStateDialog,
    required String currentUid,
  }) {
    return ListTile(
      title: Text(nickname),
      subtitle:
          isDropdownEnabled
              ? DropdownButton<String>(
                value:
                    roleOptions.contains(currentRole)
                        ? currentRole
                        : roleOptions.first,
                isExpanded: true,
                onChanged: (val) async {
                  if (val == null || val == currentRole) return;

                  final updates = <String, dynamic>{};

                  if (val == 'owner') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: const Text('주의'),
                            content: const Text(
                              '해당 사용자를 owner로 지정하시겠습니까?\n기존 owner는 editor로 변경됩니다.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('확인'),
                              ),
                            ],
                          ),
                    );
                    if (confirm != true) return;

                    final currentOwner = roles.entries.firstWhere(
                      (e) => e.value.toLowerCase() == 'owner' && e.key != uid,
                      orElse: () => const MapEntry('', ''),
                    );
                    if (currentOwner.key.isNotEmpty) {
                      updates['participants/${currentOwner.key}'] = 'editor';
                      roles[currentOwner.key] = 'editor';
                    }
                  }

                  updates['participants/$uid'] = val;
                  roles[uid] = val;

                  try {
                    await ProjectService().updateProject(
                      widget.project.id,
                      updates,
                    );
                  } catch (e) {
                    debugPrint('Error updating roles\n$e');
                  }

                  setStateDialog(() {});
                  setState(() {});
                },
                items:
                    roleOptions
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text('역할: $role'),
                          ),
                        )
                        .toList(),
              )
              : Text('역할: $currentRole'),
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
                  '${widget.project.participants.length}명',
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
