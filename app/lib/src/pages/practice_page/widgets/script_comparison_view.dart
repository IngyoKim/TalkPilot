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
