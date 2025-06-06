import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/services/database/project_stream_service.dart';

class EstimatedTimeService {
  final ProjectStreamService _projectStreamService;
  final ProjectService _projectService;
  final UserService _userService;

  final Set<String> _subscribedProjects = {};
  final Map<String, String> _prevStateMap = {};
  final Map<String, List<String>> _prevKeywordMap = {};

  EstimatedTimeService({
    required ProjectStreamService projectStreamService,
    required ProjectService projectService,
    required UserService userService,
  })  : _projectStreamService = projectStreamService,
        _projectService = projectService,
        _userService = userService;

  void streamEstimatedTime(String projectId, {bool force = false}) {
    if (_subscribedProjects.contains(projectId) && !force) return;
    _subscribedProjects.add(projectId);

    _projectStreamService.streamProject(projectId).listen((project) async {
      final script = project.script?.trim();
      final parts = project.scriptParts ?? [];
      final keywords = project.keywords ?? [];

      if (script == null || script.isEmpty) return;

      final normalizedKeywords =
          keywords
              .map((e) => e.trim().toLowerCase())
              .where((e) => e.isNotEmpty)
              .toList()
            ..sort();

      final normalizedParts =
          parts.map((e) => '${e.uid}:${e.startIndex}-${e.endIndex}').toList()
            ..sort();

      final currentState =
          '$script::${normalizedParts.join(',')}::${normalizedKeywords.join(',')}';
      final prevState = _prevStateMap[project.id];
      final prevKeywords = _prevKeywordMap[project.id] ?? [];

      final stateChanged = prevState == null || currentState != prevState;
      final keywordChanged =
          normalizedKeywords.join(',') != prevKeywords.join(',');

      if (!stateChanged && !keywordChanged && !force) return;

      _prevStateMap[project.id] = currentState;
      _prevKeywordMap[project.id] = normalizedKeywords;

      double totalTime = 0;

      if (parts.isNotEmpty) {
        for (final part in parts) {
          final start = part.startIndex;
          final end = part.endIndex;
          final uid = part.uid;

          if (start < 0 || end > script.length || start >= end) continue;

          final text = script.substring(start, end).trim();
          if (text.isEmpty) continue;

          final user = await _userService.readUser(uid);
          final cpm = user?.cpm ?? 0;
          if (cpm <= 0) continue;

          totalTime += (text.length / cpm) * 60;
        }
      } else {
        final user = await _userService.readUser(project.ownerUid);
        final cpm = user?.cpm ?? 0;
        if (cpm <= 0) return;

        totalTime = (script.length / cpm) * 60;
      }

      int keywordCount = 0;
      for (final keyword in normalizedKeywords) {
        final regex = RegExp(RegExp.escape(keyword), caseSensitive: false);
        keywordCount += regex.allMatches(script).length;
      }

      totalTime += keywordCount * 0.5;
      final newEstimatedTime = double.parse(totalTime.toStringAsFixed(2));

      if (project.estimatedTime != newEstimatedTime) {
        await _projectService.updateProject(project.id, {
          'estimatedTime': newEstimatedTime,
        });
      }
    });
  }
}
