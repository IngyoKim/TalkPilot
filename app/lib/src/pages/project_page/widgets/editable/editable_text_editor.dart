import 'package:flutter/material.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/models/script_part_model.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class EditableTextEditor extends StatefulWidget {
  final String projectId;
  final ProjectField field;
  final String label;
  final String value;
  final int maxLength;
  final bool editable;
  final List<ScriptPartModel> scriptParts;

  const EditableTextEditor({
    super.key,
    required this.projectId,
    required this.field,
    required this.label,
    required this.value,
    required this.maxLength,
    this.editable = false,
    this.scriptParts = const [],
  });

  @override
  State<EditableTextEditor> createState() => _EditableTextEditorState();
}

class _EditableTextEditorState extends State<EditableTextEditor> {
  late TextEditingController _controller;
  late String _oldText;
  late List<ScriptPartModel> _scriptParts;

  @override
  void initState() {
    super.initState();
    _oldText = widget.value;
    _scriptParts = List.from(widget.scriptParts);
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
      final oldSelection = _controller.selection;
      _controller.text = widget.value;
      final newPos = oldSelection.baseOffset.clamp(0, widget.value.length);
      _controller.selection = TextSelection.collapsed(offset: newPos);

      _oldText = widget.value;
      _scriptParts = List.from(widget.scriptParts);
    }
  }

  Color getColorForUid(String uid) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.brown,
    ];
    final uids = _scriptParts.map((e) => e.uid).toSet().toList();
    final index = uids.indexOf(uid);
    if (index == -1) return Colors.grey;
    return colors[index % colors.length];
  }

  List<String?> _mapTextIndicesToUid(List<ScriptPartModel> parts, String text) {
    List<String?> map = List<String?>.filled(text.length, null);
    for (final part in parts) {
      final start = part.startIndex.clamp(0, text.length);
      final end = part.endIndex.clamp(0, text.length);
      for (int i = start; i < end; i++) {
        map[i] = part.uid;
      }
    }
    return map;
  }

  List<InlineSpan> buildTextSpans(List<ScriptPartModel> parts, String text) {
    if (text.isEmpty) {
      return [const TextSpan(text: '(대본이 없습니다.)')];
    }

    final uidMap = _mapTextIndicesToUid(parts, text);
    List<InlineSpan> spans = [];
    String? currentUid = uidMap[0];
    int segmentStart = 0;

    for (int i = 1; i <= text.length; i++) {
      final uid = (i < text.length) ? uidMap[i] : null;

      if (uid != currentUid || i == text.length) {
        final segmentText = text.substring(segmentStart, i);
        final bgColor =
            currentUid != null
                // ignore: deprecated_member_use
                ? getColorForUid(currentUid).withOpacity(0.3)
                : Colors.transparent;

        spans.add(
          TextSpan(
            text: segmentText,
            style: TextStyle(
              backgroundColor: bgColor,
              fontWeight:
                  currentUid != null ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
        );
        currentUid = uid;
        segmentStart = i;
      }
    }

    return spans;
  }

  /// 텍스트 수정 시 파트 인덱스 자동 보정 함수
  List<ScriptPartModel> adjustScriptParts(
    List<ScriptPartModel> parts,
    int changePos,
    int changeLen,
  ) {
    if (changeLen == 0) return parts;

    List<ScriptPartModel> adjusted = [];
    int absLen = changeLen.abs();

    for (var part in parts) {
      int start = part.startIndex;
      int end = part.endIndex;

      if (changeLen > 0) {
        // 삽입: 단순 인덱스 증가
        if (start >= changePos) start += changeLen;
        if (end >= changePos) end += changeLen;
        adjusted.add(
          ScriptPartModel(uid: part.uid, startIndex: start, endIndex: end),
        );
      } else {
        if (end <= changePos) {
          adjusted.add(part);
        } else if (start >= changePos + absLen) {
          start -= absLen;
          end -= absLen;
          if (start < end) {
            adjusted.add(
              ScriptPartModel(uid: part.uid, startIndex: start, endIndex: end),
            );
          }
        } else if (start < changePos && end > changePos + absLen) {
          adjusted.add(
            ScriptPartModel(
              uid: part.uid,
              startIndex: start,
              endIndex: changePos,
            ),
          );
          adjusted.add(
            ScriptPartModel(
              uid: part.uid,
              startIndex: changePos,
              endIndex: end - absLen,
            ),
          );
        } else if (start < changePos && end > changePos) {
          adjusted.add(
            ScriptPartModel(
              uid: part.uid,
              startIndex: start,
              endIndex: changePos,
            ),
          );
        } else if (start >= changePos && end > changePos + absLen) {
          start = changePos;
          end -= absLen;
          if (start < end) {
            adjusted.add(
              ScriptPartModel(uid: part.uid, startIndex: start, endIndex: end),
            );
          }
        }
      }
    }

    return adjusted;
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
              onChanged: (text) async {
                int changePos = 0;
                while (changePos < _oldText.length &&
                    changePos < text.length &&
                    _oldText[changePos] == text[changePos]) {
                  changePos++;
                }
                int oldLenRem = _oldText.length - changePos;
                int newLenRem = text.length - changePos;

                int changeLen = newLenRem - oldLenRem;

                _scriptParts = adjustScriptParts(
                  _scriptParts,
                  changePos,
                  changeLen,
                );

                await ProjectService().updateProject(widget.projectId, {
                  widget.field.key: text,
                  ProjectField.scriptParts.key:
                      _scriptParts.map((e) => e.toMap()).toList(),
                });

                _oldText = text;
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
              child: RichText(
                text: TextSpan(
                  children: buildTextSpans(widget.scriptParts, widget.value),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
      ],
    );
  }
}
