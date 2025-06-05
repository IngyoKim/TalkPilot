import 'package:flutter/material.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class ScriptProgressService {
  final ProjectService _projectService = ProjectService();
  List<String> _scriptChunks = [];

  Future<void> loadScript(String projectId) async {
    final project = await _projectService.readProject(projectId);
    final script = project?.script ?? '';
    _scriptChunks = _splitText(script);
    debugPrint('Loaded scriptChunks: $_scriptChunks');
  }

  double calculateProgressByLastMatch(String recognizedText) {
    final recognizedWords = _prepareRecognizedWords(recognizedText);
    if (_scriptChunks.isEmpty || recognizedWords.isEmpty) return 0.0;

    final matchedFlags = List<bool>.filled(_scriptChunks.length, false);
    int lastMatchedIndex = -1;

    for (int i = 0; i < recognizedWords.length; i++) {
      final start = (lastMatchedIndex - 8).clamp(0, scriptChunks.length);
      final end = (lastMatchedIndex + 8).clamp(0, scriptChunks.length);

      for (int j = start; j < end; j++) {
        if (matchedFlags[j]) continue;
        if (recognizedWords[i] == scriptChunks[j]) {
          matchedFlags[j] = true;
          lastMatchedIndex = j;
          break;
        }
      }
    }

    if (lastMatchedIndex == -1) return 0.0;
    return (lastMatchedIndex + 1) / _scriptChunks.length;
  }

  double calculateAccuracy(String recognizedText) {
  final recognizedWords = _prepareRecognizedWords(recognizedText);
  if (recognizedWords.isEmpty || _scriptChunks.isEmpty) return 1.0;

  final matchedFlags = List<bool>.filled(_scriptChunks.length, false);

  int lastMatchedIndex = -1;
  int matchedCount = 0;

  for (int i = 0; i < recognizedWords.length; i++) {
      final start = (lastMatchedIndex - 8).clamp(0, scriptChunks.length);
      final end = (lastMatchedIndex + 8).clamp(0, scriptChunks.length);

      for (int j = start; j < end; j++) {
        if (matchedFlags[j]) continue;
        if (recognizedWords[i] == scriptChunks[j]) {
          matchedFlags[j] = true;
          lastMatchedIndex = j;
          matchedCount++;
          break;
        }
      }
    }


  return recognizedWords.isEmpty
      ? 1.0
      : (matchedCount / lastMatchedIndex).clamp(0.0, 1.0);
}

  List<String> _prepareRecognizedWords(String recognizedText) {
    return _splitText(recognizedText);
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
