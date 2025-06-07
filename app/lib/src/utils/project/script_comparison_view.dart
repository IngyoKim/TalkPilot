import 'package:flutter/material.dart';

class ScriptComparisonView extends StatelessWidget {
  final List<String> scriptChunks;
  final String recognizedText;
  final List<String> Function(String) splitText;

  const ScriptComparisonView({
    super.key,
    required this.scriptChunks,
    required this.recognizedText,
    required this.splitText,
  });

  @override
  Widget build(BuildContext context) {
    final recognizedWords = splitText(recognizedText);

    if (scriptChunks.isEmpty) {
      return const Text('');
    }

    final matchedFlags = List<bool>.filled(scriptChunks.length, false);
    int lastMatchedIndex = -1;

    for (int i = 0; i < recognizedWords.length; i++) {
      final start = (lastMatchedIndex - 8).clamp(0, scriptChunks.length);
      final end = (lastMatchedIndex + 8).clamp(0, scriptChunks.length);

      /// 이미 구현이 되었으니 주석 처리함(로그가 너무 난잡해짐)
      /// debugPrint('start: $start, end: $end');
      for (int j = start; j < end; j++) {
        if (matchedFlags[j]) continue;
        if (recognizedWords[i] == scriptChunks[j]) {
          matchedFlags[j] = true;
          lastMatchedIndex = j;
          break;
        }
      }
    }

    final scriptSpans = <InlineSpan>[];
    int idx = 0;

    while (idx < scriptChunks.length) {
      scriptSpans.add(
        TextSpan(
          text: '${scriptChunks[idx]} ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: matchedFlags[idx] ? FontWeight.bold : FontWeight.normal,
            color: matchedFlags[idx] ? Colors.deepPurple : Colors.black,
          ),
        ),
      );
      idx += 1;
    }
    return RichText(text: TextSpan(children: scriptSpans));
  }
}
