import 'package:flutter/material.dart';
import 'package:talk_pilot/src/pages/schedule_page/widgets/event_color_storage.dart';
import '../../../services/database/project_service.dart';
import '../widgets/event.dart';

class ScheduleController {
  final Map<DateTime, List<Event>> events = {};
  final Map<String, int> eventColorMap = {};
  final ProjectService _projectService = ProjectService();

  DateTime normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  List<Event> getEvents(DateTime day) => events[normalize(day)] ?? [];

  Future<void> loadColors() async {
    final map = await EventColorStorage.loadEventColors();
    eventColorMap.addAll(map);
  }

  Future<void> loadEvents(String uid) async {
    final projects = await _projectService.fetchProjects(uid);

    for (final project in projects) {
      if (project.scheduledDate != null) {
        final day = normalize(project.scheduledDate!);
        final color =
            eventColorMap[project.title] != null
                ? Color(eventColorMap[project.title]!)
                : Colors.indigo;

        events
            .putIfAbsent(day, () => [])
            .add(Event(title: project.title, color: color));
      }
    }
  }

  Future<void> saveColor(String title, Color color) async {
    eventColorMap[title] = color.value;
    await EventColorStorage.saveEventColor(title, color);
  }
}
