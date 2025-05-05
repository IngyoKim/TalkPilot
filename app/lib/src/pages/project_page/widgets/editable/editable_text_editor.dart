import 'package:flutter/material.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class EditableTextEditor extends StatefulWidget {
  final String projectId;
  final ProjectField field;
  final String label;
  final String value;
  final int maxLength;
  final bool editable;

  const EditableTextEditor({
    super.key,
    required this.projectId,
    required this.field,
    required this.label,
    required this.value,
    required this.maxLength,
    this.editable = false,
  });

  @override
  State<EditableTextEditor> createState() => _EditableTextEditorState();
}

class _EditableTextEditorState extends State<EditableTextEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EditableTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        widget.editable
            ? TextField(
              controller: _controller,
              maxLength: widget.maxLength,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (text) {
                ProjectService().updateProject(widget.projectId, {
                  widget.field.key: text,
                });
              },
            )
            : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.value.isEmpty ? '(입력 없음)' : widget.value,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
      ],
    );
  }
}
