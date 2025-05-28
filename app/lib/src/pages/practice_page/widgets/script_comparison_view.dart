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
    if (scriptChunks.isEmpty) {
      return const Text('');
    }

    final matchedFlags = List<bool>.filled(scriptChunks.length, false);
    final bigramFlags = List<bool>.filled(scriptChunks.length, false);
    final matchedRecognizedIndexes = <int>{};

    for (int i = 0; i < scriptChunks.length; i++) {
      if (matchedFlags[i]) continue;

      final start = (i - 8).clamp(0, recognizedWords.length);
      final end = (i + 8).clamp(0, recognizedWords.length);

      for (int j = start; j < end; j++) {
        if (matchedRecognizedIndexes.contains(j)) continue;
        if (isSimilar(scriptChunks[i], recognizedWords[j])) {
          matchedFlags[i] = true;
          matchedRecognizedIndexes.add(j);
          break;
        }
      }

      if (!matchedFlags[i] &&
          i < scriptChunks.length - 1 &&
          !matchedFlags[i + 1]) {
        final bigram = scriptChunks[i] + scriptChunks[i + 1];
        for (int j = start; j < end; j++) {
          if (matchedRecognizedIndexes.contains(j)) continue;
          if (isSimilar(bigram, recognizedWords[j])) {
            matchedFlags[i] = true;
            matchedFlags[i + 1] = true;
            bigramFlags[i] = true;
            bigramFlags[i + 1] = true;
            matchedRecognizedIndexes.add(j);
            break;
          }
        }
      }
    }

    final scriptSpans = <InlineSpan>[];
    int idx = 0;

    while (idx < scriptChunks.length) {
      if (bigramFlags[idx] &&
          idx + 1 < scriptChunks.length &&
          bigramFlags[idx + 1]) {
        scriptSpans.add(
          TextSpan(
            text: '${scriptChunks[idx]}${scriptChunks[idx + 1]} ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        );
        idx += 2;
      } else {
        scriptSpans.add(
          TextSpan(
            text: '${scriptChunks[idx]} ',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  matchedFlags[idx] ? FontWeight.bold : FontWeight.normal,
              color: matchedFlags[idx] ? Colors.deepPurple : Colors.black,
            ),
          ),
        );
        idx += 1;
      }
    }

    return RichText(text: TextSpan(children: scriptSpans));
  }
}
