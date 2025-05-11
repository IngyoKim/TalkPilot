import 'package:talk_pilot/src/services/database/project_service.dart';

class ScriptProgressService {
  final ProjectService _projectService = ProjectService();

  List<String> _scriptChunks = [];
  String _currentRecognizedText = '';
  double progress = 0.0;
  List<bool> _matchedFlags = [];

  Future<void> loadScript(String projectId) async {
    final project = await _projectService.readProject(projectId);
    final script = project?.script ?? '';
    _scriptChunks = _splitText(script);
    _matchedFlags = List.filled(_scriptChunks.length, false);
  }

  void updateRecognizedText(String recognizedText) {
    _currentRecognizedText = recognizedText;
    _matchedFlags = List.filled(_scriptChunks.length, false);
    progress = _calculateProgress(_currentRecognizedText);
  }

  double _calculateProgress(String recognizedText) {
    final recognizedWords = _splitText(recognizedText);
    if (_scriptChunks.isEmpty) return 0.0;

    for (final word in recognizedWords) {
      for (int i = 0; i < _scriptChunks.length; i++) {
        if (!_matchedFlags[i] && isSimilar(_scriptChunks[i], word)) {
          _matchedFlags[i] = true;
          break;
        }
      }
    }

    final matchedCount = _matchedFlags.where((v) => v).length;
    return matchedCount / _scriptChunks.length;
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

  double getProgress() => progress;

  List<String> get scriptChunks => _scriptChunks;

  List<String> getRecognizedWords() => _splitText(_currentRecognizedText);

  bool isMatchedAt(int index) => index < _matchedFlags.length && _matchedFlags[index];
}
