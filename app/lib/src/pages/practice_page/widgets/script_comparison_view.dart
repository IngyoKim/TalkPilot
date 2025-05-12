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
    final usedScriptIndexes = <int>{};

    for (int i = 0; i < recognizedWords.length; i++) {
      final word = recognizedWords[i];

      final start = (i - 10).clamp(0, scriptChunks.length);
      final end = (i + 10).clamp(0, scriptChunks.length);

      for (int j = start; j < end; j++) {
        if (usedScriptIndexes.contains(j)) continue;

        if (isSimilar(scriptChunks[j], word)) {
          matchedFlags[j] = true;
          usedScriptIndexes.add(j);
          break;
        }
      }
    }

    final scriptSpans = List<InlineSpan>.generate(scriptChunks.length, (i) {
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

    return RichText(text: TextSpan(children: scriptSpans));
  }
}
