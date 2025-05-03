import 'package:flutter/material.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/components/toast_message.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class EstimatedTimeEditor extends StatefulWidget {
  final String projectId;
  final int? initialSeconds;

  const EstimatedTimeEditor({
    super.key,
    required this.projectId,
    required this.initialSeconds,
  });

  @override
  State<EstimatedTimeEditor> createState() => _EstimatedTimeEditorState();
}

class _EstimatedTimeEditorState extends State<EstimatedTimeEditor> {
  late final TextEditingController _minController;
  late final TextEditingController _secController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final total = widget.initialSeconds ?? 0;
    _minController = TextEditingController(text: '${total ~/ 60}');
    _secController = TextEditingController(text: '${total % 60}');
  }

  @override
  void dispose() {
    _minController.dispose();
    _secController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final min = int.tryParse(_minController.text) ?? 0;
    final sec = int.tryParse(_secController.text) ?? 0;
    final total = min * 60 + sec;

    await ProjectService().updateProject(widget.projectId, {
      ProjectField.estimatedTime.key: total,
    });

    ToastMessage.show("예상 발표 시간이 저장되었습니다");
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEditing) {
      final seconds = widget.initialSeconds ?? 0;
      final display = '${seconds ~/ 60}분 ${seconds % 60}초';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: 120,
              child: Text(
                '예상 시간',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: SelectableText(
                      display,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(() => _isEditing = true),
                    child: const Icon(Icons.edit, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              '예상 시간',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Flexible(
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '분',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: TextField(
                    controller: _secController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '초',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _save, child: const Text('저장')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
