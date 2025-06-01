import 'package:flutter/material.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/pages/schedule_page/utils/event.dart';
import 'package:talk_pilot/src/pages/schedule_page/utils/event_color_storage.dart';

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
      if (project.scheduledDate != null && project.status == 'preparing') {
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
    // ignore: deprecated_member_use
    eventColorMap[title] = color.value;
    await EventColorStorage.saveEventColor(title, color);
  }
}
