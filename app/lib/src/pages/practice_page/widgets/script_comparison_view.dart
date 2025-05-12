import 'package:flutter/material.dart';

class ScriptComparisonView extends StatelessWidget {
  final List<String> scriptChunks;
  final String recognizedText;
  final bool Function(String, String) isSimilar;
  final List<String> Function(String) splitText;

  const ScriptComparisonView({
    super.key,
    required this.scriptChunks,
    required this.recognizedText,
    required this.isSimilar,
    required this.splitText,
  });

  @override
  Widget build(BuildContext context) {
    final recognizedWords = splitText(recognizedText);
    final matchedFlags = List<bool>.filled(scriptChunks.length, false);

    int scriptIndex = 0;
    int recognizedIndex = 0;

    while (scriptIndex < scriptChunks.length && recognizedIndex < recognizedWords.length) {
      if (isSimilar(scriptChunks[scriptIndex], recognizedWords[recognizedIndex])) {
        matchedFlags[scriptIndex] = true;
        recognizedIndex++;
        scriptIndex++;
      } else {
        scriptIndex++;
      }
    }

    List<InlineSpan> scriptSpans = List.generate(scriptChunks.length, (i) {
      final word = scriptChunks[i];
      final matched = matchedFlags[i];
      return TextSpan(
        text: '$word ',
        style: TextStyle(
          fontSize: 16,
          fontWeight: matched ? FontWeight.bold : FontWeight.normal,
          color: matched ? Colors.deepPurple : Colors.black,
        ),
      );
    });

    // 인식된 텍스트는 기존처럼 그대로 회색으로 출력
    List<InlineSpan> recognizedSpans = recognizedWords.map((word) {
      return TextSpan(
        text: '$word ',
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '대본:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        RichText(text: TextSpan(children: scriptSpans)),
        const SizedBox(height: 8),
        const Text(
          '인식 결과:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        RichText(text: TextSpan(children: recognizedSpans)),
      ],
    );
  }
}
