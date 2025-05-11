import 'package:talk_pilot/src/services/database/project_service.dart';

class ScriptProgressService {
  final ProjectService _projectService = ProjectService();

  List<String> _scriptChunks = [];

  Future<void> loadScript(String projectId) async {
    final project = await _projectService.readProject(projectId);
    final script = project?.script ?? '';
    _scriptChunks = _splitText(script);
  }

  double calculateProgressByLastMatch(String recognizedText) {
    final recognizedWords = _splitText(recognizedText);
    if (_scriptChunks.isEmpty || recognizedWords.isEmpty) return 0.0;

    int maxMatchedIndex = -1;

    for (final recognizedWord in recognizedWords) {
      for (int i = 0; i < _scriptChunks.length; i++) {
        if (isSimilar(_scriptChunks[i], recognizedWord)) {
          if (i > maxMatchedIndex) {
            maxMatchedIndex = i;
          }
          break;
        }
      }
    }

    if (maxMatchedIndex == -1) return 0.0;

    return (maxMatchedIndex + 1) / _scriptChunks.length;
  }

  List<String> _splitText(String text) {
    return text
        .trim()
        .replaceAll(RegExp(r'[^\uAC00-\uD7A3a-zA-Z0-9\s]'), '')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  bool isSimilar(String a, String b) {
    return a == b || a.contains(b) || b.contains(a);
  }

  List<String> get scriptChunks => _scriptChunks;

  List<String> splitText(String text) => _splitText(text);
}
