import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:talk_pilot/src/pages/schedule_page/widgets/schedule_controller.dart';

class ScheduleCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(DateTime) onPageChanged;
  final ScheduleController controller;

  const ScheduleCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      key: ValueKey(focusedDay),
      firstDay: DateTime.utc(2025, 1, 1),
      lastDay: DateTime.utc(2035, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      headerVisible: false,
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          final norm = controller.normalize(date);
          final events = controller.getEvents(norm);
          if (events.isEmpty) return null;
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: events.first.color, width: 2),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: const TextStyle(color: Colors.black),
            ),
          );
        },
      ),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.deepPurple,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
