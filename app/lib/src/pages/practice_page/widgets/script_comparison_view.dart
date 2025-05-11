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

    List<InlineSpan> scriptSpans = scriptChunks.map((scriptWord) {
      final matched = recognizedWords.any((w) => isSimilar(scriptWord, w));
      return TextSpan(
        text: '$scriptWord ',
        style: TextStyle(
          fontSize: 16,
          fontWeight: matched ? FontWeight.bold : FontWeight.normal,
          color: matched ? Colors.deepPurple : Colors.black,
        ),
      );
    }).toList();

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
