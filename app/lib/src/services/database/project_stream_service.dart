import 'package:firebase_database/firebase_database.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/database_stream_service.dart';

class ProjectStreamService {
  final DatabaseStreamService streamHelper;
  final FirebaseDatabase firebaseDatabase;
  final String basePath;

  ProjectStreamService({
    required this.streamHelper,
    required this.firebaseDatabase,
    this.basePath = 'projects',
  });

  Stream<ProjectModel> streamProject(String projectId) {
    return streamHelper.streamData<ProjectModel>(
      path: '$basePath/$projectId',
      fromMap: (map) => ProjectModel.fromMap(projectId, map),
      logTag: 'Project:$projectId',
    );
  }

  Stream<List<ProjectModel>> streamUserProjects(String uid) {
    final ref = firebaseDatabase.ref(basePath);
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
          .whereType<ProjectModel>()
          .toList();
    });
  }
}
