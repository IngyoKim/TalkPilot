import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class EstimatedTimeService {
  final UserService _userService = UserService();
  final ProjectService _projectService = ProjectService();

  Future<void> updateEstimatedTimeFromProjectId(String projectId) async {
    final project = await _projectService.readProject(projectId);
    if (project == null) return;

    final user = await _userService.readUser(project.ownerUid);
    final double cpm = user?.cpm ?? 0.0;

    final double? estimatedTime = _calculateEstimatedTime(
      text: project.script ?? '',
      cpm: cpm,
    );

    if (estimatedTime != null) {
      await _projectService.updateProject(projectId, {
        'estimatedTime': estimatedTime,
      });
    }
  }

  double? _calculateEstimatedTime({required String text, required double cpm}) {
    if (cpm <= 0 || text.trim().isEmpty) return null;
    return (text.trim().length / cpm) * 60;
  }
}
