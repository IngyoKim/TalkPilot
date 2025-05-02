import 'package:flutter/material.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class TextEditor extends StatelessWidget {
  final String projectId;
  final ProjectField field;
  final String label;
  final String value;
  final int maxLength;

  const TextEditor({
    super.key,
    required this.projectId,
    required this.field,
    required this.label,
    required this.value,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          onChanged: (text) {
            ProjectService().updateProject(projectId, {field.key: text});
          },
        ),
      ],
    );
  }
}
