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
    final usedRecognizedIndexes = <int>{};

    for (int i = 0; i < scriptChunks.length; i++) {
      for (int j = 0; j < recognizedWords.length; j++) {
        if (usedRecognizedIndexes.contains(j)) continue;

        if (isSimilar(scriptChunks[i], recognizedWords[j])) {
          matchedFlags[i] = true;
          usedRecognizedIndexes.add(j);
          break;
        }
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

    List<InlineSpan> recognizedSpans =
        recognizedWords.map((word) {
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
