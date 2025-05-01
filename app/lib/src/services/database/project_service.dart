import 'package:uuid/uuid.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';

class ProjectService {
  final DatabaseService _db = DatabaseService();
  final String basePath = 'projects';
  final _uuid = const Uuid();

  /// user쪽에도 [projectId]를 업데이트 해야함.
  /// projectModel을 return.
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
      presentationDate: null,
      script: '',
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
      'updatedAt': DateTime.now().toIso8601String(), // 자동으로 updateAt 갱신
    };
    await _db.updateDB('$basePath/$id', fullUpdates);
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
        .where((project) => project.participants.containsKey(uid))
        .toList();
  }

  /// 프로젝트의 누락된 필드 초기화
  /// 변경이 불가한 필드는 에러 유발이 가능하니 수정의 유의할 것
  Future<void> initProject(ProjectModel project) async {
    final existingMap = await _db.readDB<Map<String, dynamic>>(
      '$basePath/${project.id}',
    );
    if (existingMap == null) return;

    final updateMap = <String, dynamic>{};

    // 특정 필드가 DB에 없고, 프로젝트에 값이 존재하면 추가
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
    setIfMissing(
      'presentationDate',
      project.presentationDate?.toIso8601String(),
    );

    if (updateMap.isNotEmpty) {
      await updateProject(project.id, updateMap);
    }
  }
}
