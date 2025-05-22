import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/models/script_part_model.dart';
import 'package:talk_pilot/src/provider/project_provider.dart';
import 'package:talk_pilot/src/components/toast_message.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';

class ScriptPartPage extends StatefulWidget {
  final String projectId;
  const ScriptPartPage({super.key, required this.projectId});

  @override
  State<ScriptPartPage> createState() => _ScriptPartPageState();
}

class _ScriptPartPageState extends State<ScriptPartPage> {
  int? dragEndIndex;
  String? selectedUid;
  int? dragStartIndex;

  List<ScriptPartModel>? localScriptParts;
  Map<String, String> participantNicknames = {};

  late ProjectProvider provider;
  final GlobalKey _richTextKey = GlobalKey();
  final TextStyle _textStyle = const TextStyle(fontSize: 16);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProjectProvider>();

      await provider.refreshProject();

      final participants = provider.selectedProject?.participants ?? {};

      final nicknameResults = await Future.wait(
        participants.keys.map((uid) async {
          final user = await UserService().readUser(uid);
          return MapEntry(uid, user?.nickname ?? '로딩 중...');
        }),
      );

      setState(() {
        localScriptParts = List.from(
          provider.selectedProject?.scriptParts ?? [],
        );
        participantNicknames = Map.fromEntries(nicknameResults);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = context.read<ProjectProvider>();
  }

  /// 색상 매칭
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

  /// 파트 저장
  void _overwriteParts(ProjectModel project, int start, int end) {
    if (selectedUid == null || localScriptParts == null) {
      ToastMessage.show("참여자를 먼저 선택하세요.");
      return;
    }

    final s = start < end ? start : end;
    final e = start > end ? start : end;
    final parts = List<ScriptPartModel>.from(localScriptParts!);

    /// 파트 중복되는 부분을 덮어씌움(기존 파트는 잘림)
    final newParts = <ScriptPartModel>[];
    for (final part in parts) {
      if (e <= part.startIndex || s >= part.endIndex) {
        newParts.add(part);
      } else {
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

    /// 새로운 파트 추가
    newParts.add(
      ScriptPartModel(uid: selectedUid!, startIndex: s, endIndex: e),
    );

    /// [startIndex]로 정렬(색상을 맞춤춤)
    newParts.sort((a, b) => a.startIndex.compareTo(b.startIndex));

    setState(() {
      localScriptParts = newParts;
    });
  }

  /// 드래그 구역 표시
  List<InlineSpan> buildTextSpans(
    ProjectModel project,
    List<ScriptPartModel> scriptParts,
    int? dragStart,
    int? dragEnd,
    String script,
  ) {
    final uidMap = List<String?>.filled(script.length, null);

    for (final part in scriptParts) {
      for (
        int i = part.startIndex;
        i < part.endIndex && i < script.length;
        i++
      ) {
        uidMap[i] = part.uid;
      }
    }

    if (dragStart != null && dragEnd != null && dragStart > dragEnd) {
      final tmp = dragStart;
      dragStart = dragEnd;
      dragEnd = tmp;
    }

    List<InlineSpan> spans = [];
    String? currentUid = uidMap[0];
    int segmentStart = 0;

    for (int i = 1; i <= script.length; i++) {
      final uid = (i < script.length) ? uidMap[i] : null;
      final isInDragRange =
          dragStart != null && dragEnd != null && i > dragStart && i <= dragEnd;

      if (isInDragRange) {
        if (segmentStart < dragStart) {
          spans.add(
            _buildSpan(
              script.substring(segmentStart, dragStart),
              currentUid,
              project,
            ),
          );
        }

        spans.add(
          TextSpan(
            text: script.substring(dragStart, dragEnd),
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

      if (uid != currentUid || i == script.length) {
        spans.add(
          _buildSpan(script.substring(segmentStart, i), currentUid, project),
        );
        currentUid = uid;
        segmentStart = i;
      }
    }

    return spans;
  }

  /// 선택중인 파트 표시
  TextSpan _buildSpan(String text, String? uid, ProjectModel project) {
    return TextSpan(
      text: text,
      style: TextStyle(
        backgroundColor:
            uid != null
                // ignore: deprecated_member_use
                ? getColorForUid(uid, project).withOpacity(0.3)
                : Colors.transparent,
        fontWeight: uid != null ? FontWeight.bold : FontWeight.normal,
        color: Colors.black,
      ),
    );
  }

  /// 드래그 중인 위치 파악 및 텍스트 인덱스 계산
  int _getTextOffset(Offset globalPosition) {
    final box = _richTextKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return 0;

    final localOffset = box.globalToLocal(globalPosition);
    final renderObject = _richTextKey.currentContext?.findRenderObject();
    if (renderObject == null || renderObject is! RenderParagraph) return 0;

    final paragraph = renderObject;
    final position = paragraph.getPositionForOffset(localOffset).offset;

    return position.clamp(
      0,
      context.read<ProjectProvider>().selectedProject?.script?.length ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final project = provider.selectedProject;

    if (project == null || project.id.isEmpty || localScriptParts == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final script = project.script ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('대본 파트 할당'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await provider.updateProject({
                ProjectField.scriptParts:
                    localScriptParts!.map((e) => e.toMap()).toList(),
              });
              ToastMessage.show("저장되었습니다");
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            tooltip: '저장',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedUid,
                    hint: const Text('참여자 선택'),
                    isExpanded: true,
                    items:
                        project.participants.keys.map((uid) {
                          final nickname =
                              participantNicknames[uid] ?? '알 수 없음';
                          final role = project.participants[uid] ?? 'member';
                          return DropdownMenuItem(
                            value: uid,
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: getColorForUid(uid, project),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Flexible(child: Text('$nickname ($role)')),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (v) => setState(() => selectedUid = v),
                  ),
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
                      participantNicknames[selectedUid] ?? '알 수 없음',
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
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (details) {
                  setState(() {
                    dragStartIndex = _getTextOffset(details.globalPosition);
                    dragEndIndex = dragStartIndex;
                  });
                },
                onPanUpdate: (details) {
                  if (dragStartIndex == null) return;
                  setState(() {
                    dragEndIndex = _getTextOffset(details.globalPosition);
                  });
                },
                onPanEnd: (_) {
                  if (dragStartIndex != null && dragEndIndex != null) {
                    _overwriteParts(project, dragStartIndex!, dragEndIndex!);
                    setState(() {
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
                        localScriptParts!,
                        dragStartIndex,
                        dragEndIndex,
                        script,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
