import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/models/script_part_model.dart';
import 'package:talk_pilot/src/provider/project_provider.dart';
import 'package:talk_pilot/src/components/toast_message.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/utils/project/script_part_service.dart'; // 서비스 import

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

  final _scriptPartService = ScriptPartService(); // 서비스 인스턴스

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
                                    color: _scriptPartService.getColorForUid(
                                      uid,
                                      project,
                                    ),
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
                      color: _scriptPartService.getColorForUid(
                        selectedUid!,
                        project,
                      ),
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
                  if (dragStartIndex != null &&
                      dragEndIndex != null &&
                      selectedUid != null) {
                    setState(() {
                      localScriptParts = _scriptPartService.overwriteParts(
                        currentParts: localScriptParts!,
                        selectedUid: selectedUid!,
                        start: dragStartIndex!,
                        end: dragEndIndex!,
                      );
                      dragStartIndex = null;
                      dragEndIndex = null;
                    });
                  } else if (selectedUid == null) {
                    ToastMessage.show("참여자를 먼저 선택하세요.");
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: RichText(
                    key: _richTextKey,
                    text: TextSpan(
                      style: _textStyle,
                      children: _scriptPartService.buildTextSpans(
                        project: project,
                        scriptParts: localScriptParts!,
                        dragStart: dragStartIndex,
                        dragEnd: dragEndIndex,
                        script: script,
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
