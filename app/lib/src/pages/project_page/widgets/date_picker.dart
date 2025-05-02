import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class DatePicker extends StatelessWidget {
  final String projectId;
  final ProjectField field;
  final String label;
  final DateTime? initialValue;

  const DatePicker({
    super.key,
    required this.projectId,
    required this.field,
    required this.label,
    required this.initialValue,
  });

  String _format(DateTime? date) {
    if (date == null) return '날짜 없음';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(_format(initialValue)),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final now = DateTime.now();
        final selected = await showDatePicker(
          context: context,
          initialDate: initialValue ?? now,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 5),
        );
        if (selected != null) {
          ProjectService().updateProject(projectId, {
            field.key: selected.toIso8601String(),
          });
        }
      },
    );
  }
}
