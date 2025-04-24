import 'package:firebase_database/firebase_database.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';

class ProjectService {
  final DatabaseService _db = DatabaseService();
  final String basePath = 'projects';

  Future<void> writeProject(ProjectModel project) async {
    await _db.writeDB('$basePath/${project.id}', project.toMap());
  }

  Future<ProjectModel?> readProject(String id) async {
    final data = await _db.readDB<Map<String, dynamic>>('$basePath/$id');
    if (data == null) return null;
    return ProjectModel.fromMap(id, data);
  }

  Future<void> updateProject(String id, Map<String, dynamic> updates) async {
    await _db.updateDB('$basePath/$id', updates);
  }

  Future<void> deleteProject(String id) async {
    await _db.deleteDB('$basePath/$id');
  }

  Future<List<ProjectModel>> fetchUserProjects(String uid) async {
    return await _db.fetchDB<ProjectModel>(
      path: basePath,
      fromMap: (map) => ProjectModel.fromMap(map['id'], map),
      query: FirebaseDatabase.instance
          .ref(basePath)
          .orderByChild('participants/$uid')
          .equalTo(true),
    );
  }
}
