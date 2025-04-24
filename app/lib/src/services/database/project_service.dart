import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';

class ProjectService {
  final DatabaseService _db = DatabaseService();
  final String basePath = 'projects';
  final _uuid = const Uuid();

  Future<ProjectModel> writeProject({
    required String name,
    required String description,
    required String ownerUid,
    required List<String> participantUids,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    final project = ProjectModel(
      id: id,
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
      ownerUid: ownerUid,
      participantUids: participantUids,
      status: 'preparing',
    );

    await _db.writeDB('$basePath/$id', project.toMap());
    return project;
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

  Future<List<ProjectModel>> fetchProjects(String uid) async {
    final snapshot = await FirebaseDatabase.instance.ref(basePath).get();

    if (!snapshot.exists) return [];

    return snapshot.children
        .map((child) {
          final map = Map<String, dynamic>.from(child.value as Map);
          final project = ProjectModel.fromMap(child.key!, map);
          return project;
        })
        .where((project) => project.participantUids.contains(uid))
        .toList();
  }
}
