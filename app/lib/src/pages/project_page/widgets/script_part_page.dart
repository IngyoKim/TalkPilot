import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/models/script_part_model.dart';
import 'package:talk_pilot/src/provider/project_provider.dart';

// ignore_for_file: deprecated_member_use
class ScriptPartPage extends StatefulWidget {
  final String projectId;
  const ScriptPartPage({super.key, required this.projectId});

  @override
  State<ScriptPartPage> createState() => _ScriptPartPageState();
}

class _ScriptPartPageState extends State<ScriptPartPage> {
  String? selectedUid;
  int? dragStartIndex;
  int? dragEndIndex;

  final GlobalKey _richTextKey = GlobalKey();
  final TextStyle _textStyle = const TextStyle(fontSize: 16);

  late List<ScriptPartModel> scriptParts;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _initScriptParts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initScriptParts();
  }

  void _initScriptParts() {
    final project = context.read<ProjectProvider>().projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse:
          () => ProjectModel(
            id: '',
            title: '',
            description: '',
            ownerUid: '',
            participants: {},
            status: '',
          ),
    );
    scriptParts = List<ScriptPartModel>.from(project.scriptParts ?? []);
    _text = project.script ?? '';
  }

  Color getColorForUid(String uid, ProjectModel project) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.brown,
    ];
    final index = project.participants.keys.toList().indexOf(uid);
    return colors[index % colors.length];
  }

  List<String?> _mapTextIndicesToUid(
    ProjectModel project,
    List<ScriptPartModel> scriptParts,
  ) {
    List<String?> map = List<String?>.filled(_text.length, null);

    for (final part in scriptParts) {
      final start = part.startIndex.clamp(0, _text.length);
      final end = part.endIndex.clamp(0, _text.length);
      for (int i = start; i < end; i++) {
        map[i] = part.uid;
      }
    }

    return map;
  }

  List<InlineSpan> buildTextSpans(
    ProjectModel project,
    List<ScriptPartModel> scriptParts,
    int? dragStart,
    int? dragEnd,
  ) {
    if (_text.isEmpty) return [const TextSpan(text: '대본이 없습니다.')];

    final uidMap = _mapTextIndicesToUid(project, scriptParts);

    if (dragStart != null && dragEnd != null && dragStart > dragEnd) {
      final tmp = dragStart;
      dragStart = dragEnd;
      dragEnd = tmp;
    }

    List<InlineSpan> spans = [];
    String? currentUid = uidMap[0];
    int segmentStart = 0;

    for (int i = 1; i <= _text.length; i++) {
      final uid = (i < _text.length) ? uidMap[i] : null;

      final isInDragRange =
          dragStart != null && dragEnd != null && i > dragStart && i <= dragEnd;

      if (isInDragRange) {
        if (segmentStart < dragStart) {
          final segmentText = _text.substring(segmentStart, dragStart);
          final bgColor =
              currentUid != null
                  ? getColorForUid(currentUid, project).withOpacity(0.3)
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
        }

        final dragText = _text.substring(dragStart, dragEnd);
        spans.add(
          TextSpan(
            text: dragText,
            style: const TextStyle(
              backgroundColor: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        );

        segmentStart = dragEnd;
        currentUid = null;
        i = dragEnd;
        dragStart = null;
        dragEnd = null;
        continue;
      }

      if (uid != currentUid || i == _text.length) {
        final segmentText = _text.substring(segmentStart, i);
        final bgColor =
            currentUid != null
                ? getColorForUid(currentUid, project).withOpacity(0.3)
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

  int _getBestTextPositionFromLocalOffset(Offset localOffset) {
    final renderObject = _richTextKey.currentContext?.findRenderObject();
    if (renderObject == null || renderObject is! RenderParagraph) {
      return 0;
    }
    final renderParagraph = renderObject;

    // 후보 좌표: 현재 위치와 왼쪽 1~2글자 범위로 보정 (글자 넓이 기준으로)
    final textStyle = _textStyle;
    final textPainter = TextPainter(
      text: TextSpan(text: _text, style: textStyle),
      maxLines: null,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: renderParagraph.size.width);

    double avgCharWidth = textPainter.size.width / _text.length;
    // 보정할 오프셋 후보군 생성 (현재 위치와 왼쪽으로 1, 2 글자 너비만큼 이동한 위치)
    final candidates = [
      localOffset,
      Offset(localOffset.dx - avgCharWidth, localOffset.dy),
      Offset(localOffset.dx - avgCharWidth * 2, localOffset.dy),
    ];

    int bestOffset = 0;
    double bestDistance = double.infinity;

    for (final offset in candidates) {
      final pos = renderParagraph.getPositionForOffset(offset).offset;
      final caretOffset = renderParagraph.getOffsetForCaret(
        TextPosition(offset: pos),
        Rect.zero,
      );

      final dist = (caretOffset - offset).distance;

      if (dist < bestDistance) {
        bestDistance = dist;
        bestOffset = pos;
      }
    }

    return bestOffset.clamp(0, _text.length);
  }

  int _getTextPositionFromGlobalOffset(Offset globalPosition) {
    final box = _richTextKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return 0;

    final localOffset = box.globalToLocal(globalPosition);
    return _getBestTextPositionFromLocalOffset(localOffset);
  }

  void _overwriteParts(int start, int end) {
    final s = start < end ? start : end;
    final e = start > end ? start : end;

    // 겹치는 기존 파트를 겹치지 않는 영역만 남기도록 수정
    final List<ScriptPartModel> newParts = [];
    for (final part in scriptParts) {
      if (e <= part.startIndex || s >= part.endIndex) {
        // 겹치지 않는 부분은 그대로 유지
        newParts.add(part);
      } else {
        // 겹치는 부분은 기존 파트를 잘라서 겹치지 않는 부분만 남김
        if (part.startIndex < s) {
          newParts.add(
            ScriptPartModel(
              uid: part.uid,
              startIndex: part.startIndex,
              endIndex: s,
            ),
          );
        }
        if (part.endIndex > e) {
          newParts.add(
            ScriptPartModel(
              uid: part.uid,
              startIndex: e,
              endIndex: part.endIndex,
            ),
          );
        }
      }
    }

    // 새 파트 추가
    newParts.add(
      ScriptPartModel(uid: selectedUid!, startIndex: s, endIndex: e),
    );

    scriptParts = newParts;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final project = provider.projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse:
          () => ProjectModel(
            id: '',
            title: '',
            description: '',
            ownerUid: '',
            participants: {},
            status: '',
          ),
    );

    final participants = project.participants;

    return Scaffold(
      appBar: AppBar(
        title: const Text('대본 파트 할당'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final provider = context.read<ProjectProvider>();
              await provider.updateProject({
                ProjectField.scriptParts:
                    scriptParts.map((e) => e.toMap()).toList(),
              });
              Navigator.pop(context);
            },
            tooltip: '저장',
          ),
        ],
      ),
      body:
          project.id.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: selectedUid,
                          hint: const Text('참여자 선택'),
                          isExpanded: false,
                          items:
                              participants.entries
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 14,
                                            height: 14,
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: getColorForUid(
                                                e.key,
                                                project,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Text('${e.value} (${e.key})'),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => selectedUid = v),
                        ),
                        const SizedBox(width: 12),
                        if (selectedUid != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: getColorForUid(selectedUid!, project),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              selectedUid!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onPanStart: (details) {
                              final startPos = _getTextPositionFromGlobalOffset(
                                details.globalPosition,
                              );
                              setState(() {
                                dragStartIndex = startPos;
                                dragEndIndex = startPos;
                              });
                            },
                            onPanUpdate: (details) {
                              if (dragStartIndex == null) return;
                              final pos = _getTextPositionFromGlobalOffset(
                                details.globalPosition,
                              );
                              setState(() {
                                dragEndIndex = pos;
                              });
                            },
                            onPanEnd: (details) {
                              if (dragStartIndex != null &&
                                  dragEndIndex != null) {
                                setState(() {
                                  _overwriteParts(
                                    dragStartIndex!,
                                    dragEndIndex!,
                                  );
                                  dragStartIndex = null;
                                  dragEndIndex = null;
                                });
                              }
                            },
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(8),
                              child: RichText(
                                key: _richTextKey,
                                text: TextSpan(
                                  style: _textStyle,
                                  children: buildTextSpans(
                                    project,
                                    scriptParts,
                                    dragStartIndex,
                                    dragEndIndex,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
