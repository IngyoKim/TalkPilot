import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class DatePicker extends StatelessWidget {
  final String projectId;
  final ProjectField field;
  final String label;
  final DateTime? initialValue;
  final bool editable;

  const DatePicker({
    super.key,
    required this.projectId,
    required this.field,
    required this.label,
    required this.initialValue,
    this.editable = true,
  });

  String _format(DateTime? date) {
    if (date == null) return '날짜 없음';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              '발표 날짜',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _format(initialValue),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 4),
                if (editable)
                  GestureDetector(
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
                    child: const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.calendar_today, size: 18),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
