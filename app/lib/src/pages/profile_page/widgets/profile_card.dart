import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String nickname;
  final String realName;
  final String? profileImageUrl;
  final bool isEditing;
  final TextEditingController nicknameController;
  final VoidCallback onToggleEdit;
  final ValueChanged<String> onNicknameSubmit;

  const ProfileCard({
    super.key,
    required this.nickname,
    required this.realName,
    required this.profileImageUrl,
    required this.isEditing,
    required this.nicknameController,
    required this.onToggleEdit,
    required this.onNicknameSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage:
                  profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
              child:
                  profileImageUrl == null
                      ? const Icon(Icons.person, size: 45)
                      : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isEditing
                      ? TextField(
                        controller: nicknameController..text = nickname,
                        decoration: const InputDecoration(
                          hintText: '닉네임 입력',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        autofocus: true,
                        onSubmitted: onNicknameSubmit,
                      )
                      : Row(
                        children: [
                          Expanded(
                            child: Text(
                              nickname.isNotEmpty ? nickname : '닉네임 없음',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(isEditing ? Icons.close : Icons.edit),
                            onPressed: onToggleEdit,
                          ),
                        ],
                      ),
                  const SizedBox(height: 6),
                  Text(
                    'Email: $realName',
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
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
