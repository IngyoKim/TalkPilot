import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String nickname;
  final String realName;
  final bool isEditing;
  final TextEditingController nicknameController;
  final VoidCallback onToggleEdit;
  final ValueChanged<String> onNicknameSubmit;

  const ProfileCard({
    super.key,
    required this.nickname,
    required this.realName,
    required this.isEditing,
    required this.nicknameController,
    required this.onToggleEdit,
    required this.onNicknameSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: isEditing
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
                      : Text(
                          '닉네임: $nickname',
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
            const SizedBox(height: 10),
            Text('이름: $realName', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
