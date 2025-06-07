import 'package:uuid/uuid.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';

class ProjectService {
  final DatabaseService _db;
  final FirebaseDatabase _firebaseDatabase;
  final String basePath = 'projects';
  final _uuid = const Uuid();

  ProjectService({
    DatabaseService? databaseService,
    FirebaseDatabase? firebaseDatabase,
  })  : _db = databaseService ?? DatabaseService(),
        _firebaseDatabase = firebaseDatabase ?? FirebaseDatabase.instance;

  Future<ProjectModel> writeProject({
    required String title,
    required String description,
    required String ownerUid,
    required Map<String, String> participants,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    final project = ProjectModel(
      id: id,
      title: title,
      description: description,
      createdAt: now,
      updatedAt: now,
      ownerUid: ownerUid,
      participants: participants,
      status: 'preparing',
      estimatedTime: 0,
      score: 0,
      scheduledDate: null,
      script: '',
      memo: '',
      scriptParts: [],
      keywords: [],
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
    final fullUpdates = {
      ...updates,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _db.updateDB('$basePath/$id', fullUpdates);
  }

  Future<void> deleteProject(String id) async {
    await _db.deleteDB('$basePath/$id');
  }

  Future<List<ProjectModel>> fetchProjects(String uid) async {
    final snapshot = await _firebaseDatabase.ref(basePath).get();

    if (!snapshot.exists) return [];

    return snapshot.children
        .map((child) {
          final map = Map<String, dynamic>.from(child.value as Map);
          return ProjectModel.fromMap(child.key!, map);
        })
        .where((project) => project.participants.containsKey(uid))
        .toList();
  }

  Future<void> initProject(ProjectModel project) async {
    final existingMap = await _db.readDB<Map<String, dynamic>>(
      '$basePath/${project.id}',
    );
    if (existingMap == null) return;

    final updateMap = <String, dynamic>{};

    void setIfMissing(String key, dynamic value) {
      final isMissing =
          !existingMap.containsKey(key) || existingMap[key] == null;
      if (isMissing && value != null) {
        updateMap[key] = value;
      }
    }

    setIfMissing('estimatedTime', project.estimatedTime);
    setIfMissing('score', project.score);
    setIfMissing('status', project.status);
    setIfMissing('script', project.script);
    setIfMissing('presentationDate', project.scheduledDate?.toIso8601String());
    setIfMissing('memo', project.memo);
    setIfMissing('scriptParts', project.scriptParts);
    setIfMissing('keywords', project.keywords);

    if (updateMap.isNotEmpty) {
      await updateProject(project.id, updateMap);
    }
  }
}
