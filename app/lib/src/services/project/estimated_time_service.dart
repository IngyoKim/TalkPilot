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
      if (script == null || script.isEmpty) return;

      final prevScript = _prevScriptMap[project.id];

      if (!_initializedProjects.contains(project.id)) {
        _prevScriptMap[project.id] = script;
        _initializedProjects.add(project.id);
        return;
      }

      if (script == prevScript) return;

      _prevScriptMap[project.id] = script;

      final user = await _userService.readUser(project.ownerUid);
      final cpm = user?.cpm ?? 0.0;
      if (cpm <= 0) return;

      final estimatedTime = double.parse(
        ((script.length / cpm) * 60).toStringAsFixed(2),
      );

      await _projectService.updateProject(project.id, {
        'estimatedTime': estimatedTime,
      });
    });
  }
}
