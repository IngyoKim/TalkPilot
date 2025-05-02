import 'package:firebase_database/firebase_database.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

extension ProjectStreamService on ProjectService {
  /// 특정 프로젝트를 실시간으로 구독
  Stream<ProjectModel> streamProject(String projectId) {
    final ref = FirebaseDatabase.instance.ref('$basePath/$projectId');
    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        throw Exception('No data found for project: $projectId');
      }
      return ProjectModel.fromMap(projectId, Map<String, dynamic>.from(data));
    });
  }

  /// 해당 사용자가 포함된 프로젝트 목록을 실시간 구독
  Stream<List<ProjectModel>> streamUserProjects(String uid) {
    final ref = FirebaseDatabase.instance.ref(basePath);
    return ref.onValue.map((event) {
      if (!event.snapshot.exists) return [];

      return event.snapshot.children
          .map((child) {
            final data = child.value as Map?;
            if (data == null) return null;

            final model = ProjectModel.fromMap(
              child.key!,
              Map<String, dynamic>.from(data),
            );
            return model.participants.containsKey(uid) ? model : null;
          })
          .whereType<ProjectModel>() // null 필터링
          .toList();
    });
  }
}
