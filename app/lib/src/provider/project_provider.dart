import 'package:flutter/material.dart';

import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/models/project_model.dart';

import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final UserService _userService = UserService();
  final List<ProjectModel> _projects = [];

  List<ProjectModel> get projects => List.unmodifiable(_projects);
  Future<void> loadUserProjects(String uid) async {
    final projects = await _projectService.fetchProjects(uid);
    final userProjects =
        projects.where((p) => p.participants.containsValue(uid)).toList();
    _projects
      ..clear()
      ..addAll(userProjects);
    notifyListeners();
  }

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

    final updatedUser = currentUser.copyWith(
      projectIds: updatedProjectIds,
      updatedAt: DateTime.now(),
    );

    await _userService.updateUser(updatedUser);

    _projects.insert(0, newProject);
    notifyListeners();
  }

  Future<void> updateProject(
    String projectId,
    Map<String, dynamic> updates,
  ) async {
    await _projectService.updateProject(projectId, updates);
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final updated = ProjectModel.fromMap(projectId, {
        ..._projects[index].toMap(),
        ...updates,
      });
      _projects[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    await _projectService.deleteProject(projectId);
    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
  }
}
