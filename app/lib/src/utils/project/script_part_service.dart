import 'package:flutter/material.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/models/script_part_model.dart';

class ScriptPartService {
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

  List<ScriptPartModel> overwriteParts({
    required List<ScriptPartModel> currentParts,
    required String selectedUid,
    required int start,
    required int end,
  }) {
    final s = start < end ? start : end;
    final e = start > end ? start : end;
    final parts = List<ScriptPartModel>.from(currentParts);

    final newParts = <ScriptPartModel>[];

    for (final part in parts) {
      if (e <= part.startIndex || s >= part.endIndex) {
        newParts.add(part);
      } else {
        if (part.startIndex < s) {
          newParts.add(ScriptPartModel(
            uid: part.uid,
            startIndex: part.startIndex,
            endIndex: s,
          ));
        }
        if (part.endIndex > e) {
          newParts.add(ScriptPartModel(
            uid: part.uid,
            startIndex: e,
            endIndex: part.endIndex,
          ));
        }
      }
    }

    newParts.add(ScriptPartModel(uid: selectedUid, startIndex: s, endIndex: e));
    newParts.sort((a, b) => a.startIndex.compareTo(b.startIndex));

    return newParts;
  }

  List<InlineSpan> buildTextSpans({
    required ProjectModel project,
    required List<ScriptPartModel> scriptParts,
    int? dragStart,
    int? dragEnd,
    required String script,
  }) {
    final uidMap = List<String?>.filled(script.length, null);

    for (final part in scriptParts) {
      for (int i = part.startIndex; i < part.endIndex && i < script.length; i++) {
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
          spans.add(_buildSpan(
            script.substring(segmentStart, dragStart),
            currentUid,
            project,
          ));
        }

        spans.add(TextSpan(
          text: script.substring(dragStart, dragEnd),
          style: const TextStyle(
            backgroundColor: Colors.yellowAccent,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ));

        segmentStart = dragEnd;
        currentUid = null;
        i = dragEnd;
        dragStart = null;
        dragEnd = null;
        continue;
      }

      if (uid != currentUid || i == script.length) {
        spans.add(_buildSpan(script.substring(segmentStart, i), currentUid, project));
        currentUid = uid;
        segmentStart = i;
      }
    }

    return spans;
  }

  TextSpan _buildSpan(String text, String? uid, ProjectModel project) {
    return TextSpan(
      text: text,
      style: TextStyle(
        backgroundColor: uid != null
            ? getColorForUid(uid, project).withOpacity(0.3)
            : Colors.transparent,
        fontWeight: uid != null ? FontWeight.bold : FontWeight.normal,
        color: Colors.black,
      ),
    );
  }
}
