import 'package:talk_pilot/src/services/database/project_service.dart';

class ScriptProgressService {
  final ProjectService _projectService = ProjectService();

  List<String> _scriptChunks = [];
  final Set<int> _matchedScriptIndexes = {};

  Future<void> loadScript(String projectId) async {
    final project = await _projectService.readProject(projectId);
    final script = project?.script ?? '';
    _scriptChunks = _splitText(script);
    _matchedScriptIndexes.clear();
  }

  double calculateProgressByLastMatch(String recognizedText) {
    final recognizedWords = _prepareRecognizedWords(recognizedText);
    if (_scriptChunks.isEmpty || recognizedWords.isEmpty) return 0.0;

    final usedRecognizedIndexes = <int>{};
    int lastMatchedScriptIndex = -1;
    int lastMatchedRecognizedIndex = -1;

    for (int i = 0; i < _scriptChunks.length; i++) {
      if (_matchedScriptIndexes.contains(i)) continue;

      final start = (lastMatchedRecognizedIndex + 1 - 5).clamp(0, recognizedWords.length);
      final end = (lastMatchedRecognizedIndex + 1 + 5).clamp(0, recognizedWords.length);

      for (int j = start; j < end; j++) {
        if (usedRecognizedIndexes.contains(j)) continue;

        if (isSimilar(_scriptChunks[i], recognizedWords[j])) {
          _matchedScriptIndexes.add(i);
          usedRecognizedIndexes.add(j);
          lastMatchedRecognizedIndex = j;
          lastMatchedScriptIndex = i;
          break;
        }
      }
    }

    if (lastMatchedScriptIndex == -1) return 0.0;
    return (lastMatchedScriptIndex + 1) / _scriptChunks.length;
  }

  double calculateAccuracy(String recognizedText) {
    final recognizedWords = _prepareRecognizedWords(recognizedText);
    if (recognizedWords.isEmpty || _scriptChunks.isEmpty) return 1.0;

    final matchedFlags = List<bool>.filled(_scriptChunks.length, false);
    final usedRecognizedIndexes = <int>{};
    int lastMatchedRecognizedIndex = -1;

    for (int i = 0; i < _scriptChunks.length; i++) {
      if (_matchedScriptIndexes.contains(i)) continue;

      final start = (lastMatchedRecognizedIndex + 1 - 5).clamp(0, recognizedWords.length);
      final end = (lastMatchedRecognizedIndex + 1 + 5).clamp(0, recognizedWords.length);

      for (int j = start; j < end; j++) {
        if (usedRecognizedIndexes.contains(j)) continue;

        if (isSimilar(_scriptChunks[i], recognizedWords[j])) {
          _matchedScriptIndexes.add(i);
          matchedFlags[i] = true;
          usedRecognizedIndexes.add(j);
          lastMatchedRecognizedIndex = j;
          break;
        }
      }
    }

    final lastIndex = matchedFlags.lastIndexWhere((flag) => flag);
    if (lastIndex == -1) return 1.0;

    final matchedCount = matchedFlags.where((flag) => flag).length;
    return matchedCount / (lastIndex + 1);
  }

  List<String> _prepareRecognizedWords(String recognizedText) {
    final rawWords = _splitText(recognizedText);
    final seen = <String>{};
    final deduplicated = <String>[];

    for (final word in rawWords) {
      if (!seen.contains(word)) {
        seen.add(word);
        deduplicated.add(word);
      }
    }

    return deduplicated.length > 100
        ? deduplicated.sublist(deduplicated.length - 100)
        : deduplicated;
  }

  bool isSimilar(String a, String b) {
    final normA = a.replaceAll(' ', '');
    final normB = b.replaceAll(' ', '');
    if ((normA.length - normB.length).abs() > 2) return false;
    final sim = _similarity(normA, normB);
    return sim >= 0.7;
  }

  double _similarity(String a, String b) {
    int distance = _levenshtein(a.toLowerCase(), b.toLowerCase());
    int maxLength = a.length > b.length ? a.length : b.length;
    if (maxLength == 0) return 1.0;
    return 1.0 - (distance / maxLength);
  }

  int _levenshtein(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    List<List<int>> dp = List.generate(
      len1 + 1,
      (_) => List.filled(len2 + 1, 0),
    );

    for (int i = 0; i <= len1; i++) {
      for (int j = 0; j <= len2; j++) {
        if (i == 0) {
          dp[i][j] = j;
        } else if (j == 0) {
          dp[i][j] = i;
        } else if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + [
            dp[i - 1][j],
            dp[i][j - 1],
            dp[i - 1][j - 1],
          ].reduce((a, b) => a < b ? a : b);
        }
      }
    }

    return dp[len1][len2];
  }

  List<String> _splitText(String text) {
    return text
        .trim()
        .replaceAll(RegExp(r'[^\uAC00-\uD7A3a-zA-Z0-9\s]'), '')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  List<String> get scriptChunks => _scriptChunks;
  List<String> splitText(String text) => _splitText(text);
}
