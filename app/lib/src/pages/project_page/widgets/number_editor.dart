import 'package:flutter/material.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class NumberEditor extends StatelessWidget {
  final String projectId;
  final ProjectField field;
  final String label;
  final int? value;

  const NumberEditor({
    super.key,
    required this.projectId,
    required this.field,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value?.toString() ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          onChanged: (text) {
            final parsed = int.tryParse(text);
            if (parsed != null) {
              ProjectService().updateProject(projectId, {field.key: parsed});
            }
          },
        ),
      ],
    );
  }
}
