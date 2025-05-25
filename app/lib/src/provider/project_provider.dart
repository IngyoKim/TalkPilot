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

  /// 프로젝트 초기화
  Future<void> initAllProjects(String uid) async {
    final allProjects = await _projectService.fetchProjects(uid);
    for (final project in allProjects) {
      await _projectService.initProject(project);
    }
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
    int? estimatedTime,
  }) async {
    final newProject = await _projectService.writeProject(
      title: title,
      description: description,
      ownerUid: currentUser.uid,
      participants: {currentUser.uid: "owner"},
    );

    final updatedProjectIds = {
      ...?currentUser.projectIds,
      newProject.id: newProject.status,
    };

    await _userService.updateUser(currentUser.uid, {
      "projectIds": updatedProjectIds,
    });

    /// 로컬에 추가된 프로젝트 반영
    /// refresh 필요 없음
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
  Future<void> deleteProject(String projectId) async {
    /// 먼저 프로젝트를 찾음.
    final project = _projects.firstWhere(
      (p) => p.id == projectId,
      orElse:
          () =>
              _selectedProject ??
              (throw Exception('프로젝트를 찾을 수 없습니다: $projectId')),
    );

    /// 모든 참여자의 projectIds 항목에서도 제거
    for (final uid in project.participants.keys) {
      final user = await _userService.readUser(uid);
      if (user == null || user.projectIds == null) continue;

      final updatedProjectIds = {...user.projectIds!};
      if (updatedProjectIds.containsKey(projectId)) {
        updatedProjectIds.remove(projectId);
        await _userService.updateUser(uid, {'projectIds': updatedProjectIds});
      }
    }

    /// 프로젝트 삭제
    await _projectService.deleteProject(projectId);

    /// 로컬 상태에서도 제거
    _projects.removeWhere((p) => p.id == projectId);
    if (_selectedProject?.id == projectId) {
      _selectedProject = null;
    }

    notifyListeners();
  }
}
