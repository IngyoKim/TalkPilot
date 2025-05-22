import 'package:talk_pilot/src/models/script_part_model.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/services/database/project_stream_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';

class EstimatedTimeService {
  final _projectService = ProjectService();
  final _userService = UserService();

  final Set<String> _subscribedProjects = {};
  final Map<String, String?> _prevScriptMap = {};
  final Set<String> _initializedProjects = {};

  void streamEstimatedTime(String projectId) {
    if (_subscribedProjects.contains(projectId)) return;
    _subscribedProjects.add(projectId);

    _projectService.streamProject(projectId).listen((project) async {
      final script = project.script?.trim();
      final List<ScriptPartModel>? parts = project.scriptParts;

      if (script == null || script.isEmpty) return;

      if (parts == null || parts.isEmpty) {
        final user = await _userService.readUser(project.ownerUid);
        final cpm = user?.cpm ?? 0;
        if (cpm <= 0) return;

        final time = (script.length / cpm) * 60;
        final estimatedTime = double.parse(time.toStringAsFixed(2));

        if (project.estimatedTime != estimatedTime) {
          await _projectService.updateProject(project.id, {
            'estimatedTime': estimatedTime,
          });
        }

        return;
      }

      final currentState = '$script::${parts.map((e) => e.toString()).join()}';
      final prevState = _prevScriptMap[project.id];

      if (!_initializedProjects.contains(project.id)) {
        _prevScriptMap[project.id] = currentState;
        _initializedProjects.add(project.id);
        return;
      }

      if (currentState == prevState) return;
      _prevScriptMap[project.id] = currentState;

      double totalTime = 0;

      for (final part in parts) {
        final int start = part.startIndex;
        final int end = part.endIndex;
        final String uid = part.uid;

        if (start < 0 || end > script.length || start >= end) continue;

        final text = script.substring(start, end).trim();
        if (text.isEmpty) continue;

        final user = await _userService.readUser(uid);
        final cpm = user?.cpm ?? 0;
        if (cpm <= 0) continue;

        final time = (text.length / cpm) * 60;
        totalTime += time;
      }

      final newEstimatedTime = double.parse(totalTime.toStringAsFixed(2));

      if (project.estimatedTime != newEstimatedTime) {
        await _projectService.updateProject(project.id, {
          'estimatedTime': newEstimatedTime,
        });
      }
    });
  }
}
