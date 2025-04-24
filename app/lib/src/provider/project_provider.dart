import 'package:flutter/material.dart';

import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/models/project_model.dart';

import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final UserService _userService = UserService();

  final List<ProjectModel> _projects = [];
  ProjectModel? _selectedProject;

  List<ProjectModel> get projects => List.unmodifiable(_projects);
  ProjectModel? get selectedProject => _selectedProject;

  set selectedProject(ProjectModel? project) {
    _selectedProject = project;
    notifyListeners();
  }

  /// 프로젝트 리스트 불러오기
  Future<void> loadProjects(String uid) async {
    final allProjects = await _projectService.fetchProjects(uid);
    final userProjects =
        allProjects.where((p) => p.participants.containsKey(uid)).toList();
    _projects
      ..clear()
      ..addAll(userProjects);
    notifyListeners();
  }

  /// 프로젝트 생성
  Future<void> createProject({
    required String title,
    required String description,
    required UserModel currentUser,
  }) async {
    final newProject = await _projectService.writeProject(
      title: title,
      description: description,
      ownerUid: currentUser.uid,
      participants: {currentUser.uid: "Owner"},
    );

    final updatedProjectIds = {
      ...?currentUser.projectIds,
      newProject.id: newProject.status,
    };

    await _userService.updateUser(currentUser.uid, {
      "projectIds": updatedProjectIds,
      "updatedAt": DateTime.now().toIso8601String(),
    });

    _projects.insert(0, newProject);
    _selectedProject = newProject;
    notifyListeners();
  }

  /// 프로젝트 새로고침
  Future<void> refreshProject() async {
    if (_selectedProject == null) return;
    final latest = await _projectService.readProject(_selectedProject!.id);
    if (latest != null) {
      final index = _projects.indexWhere((p) => p.id == latest.id);
      if (index != -1) _projects[index] = latest;
      _selectedProject = latest;
      notifyListeners();
    }
  }

  /// 프로젝트 업데이트
  Future<void> updateProject(Map<ProjectField, dynamic> updates) async {
    if (_selectedProject == null) return;
    final updateMap = {
      for (final e in updates.entries) e.key.key: e.value,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _projectService.updateProject(_selectedProject!.id, updateMap);
    await refreshProject(); // 업데이트한 정보로 갱신
  }

  /// 프로젝트 삭제
  Future<void> deleteProject() async {
    if (_selectedProject == null) return;
    await _projectService.deleteProject(_selectedProject!.id);
    _projects.removeWhere((p) => p.id == _selectedProject!.id);
    _selectedProject = null;
    notifyListeners();
  }
}
