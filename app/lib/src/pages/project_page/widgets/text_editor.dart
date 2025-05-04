import 'package:flutter/material.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class TextEditor extends StatefulWidget {
  final String projectId;
  final ProjectField field;
  final String label;
  final String value;
  final int maxLength;
  final bool editable;

  const TextEditor({
    super.key,
    required this.projectId,
    required this.field,
    required this.label,
    required this.value,
    required this.maxLength,
    this.editable = true,
  });

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
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
  void didUpdateWidget(covariant TextEditor oldWidget) {
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
        TextField(
          controller: _controller,
          maxLength: widget.maxLength,
          maxLines: null,
          enabled: widget.editable,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          onChanged:
              widget.editable
                  ? (text) {
                    ProjectService().updateProject(widget.projectId, {
                      widget.field.key: text,
                    });
                  }
                  : null,
        ),
      ],
    );
  }
}
