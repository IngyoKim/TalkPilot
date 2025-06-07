import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:talk_pilot/src/pages/schedule_page/utils/event.dart';
import 'package:talk_pilot/src/pages/schedule_page/widgets/event_list.dart';
import 'package:talk_pilot/src/pages/schedule_page/widgets/schedule_controller.dart';

import 'package:talk_pilot/src/pages/schedule_page/components/schedule_calendar.dart';
import 'package:talk_pilot/src/pages/schedule_page/components/schedule_header.dart';
import 'package:talk_pilot/src/pages/schedule_page/components/schedule_color_dialog.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final controller = ScheduleController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  final DateTime _minDate = DateTime.utc(2025, 1, 1);
  final DateTime _maxDate = DateTime.utc(2035, 12, 31);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await controller.loadColors();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await controller.loadEvents(uid);
      if (!mounted) return;
      setState(() {});
    }
  }

  void _onDayTapped(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = controller.normalize(selected);
      _focusedDay = focused;
    });
  }

  Future<void> _onEdit(int index, Event event) async {
    final day = _selectedDay;
    if (day == null) return;

    final newColor = await showColorDialog(
      context: context,
      initialColor: event.color,
    );

    if (newColor == null) return;

    final events = controller.getEvents(day);
    final updated = Event(title: event.title, color: newColor);

    await controller.saveColor(event.title, newColor);

    setState(() {
      events[index] = updated;
    });
  }

  void _showMonthPicker() {
    Event.showMonthYearPickerDialog(
      context: context,
      initialYear: _focusedDay.year,
      initialMonth: _focusedDay.month,
      onSelected: (year, month) {
        final newDate = DateTime(year, month);
        if (newDate.isBefore(_minDate) || newDate.isAfter(_maxDate)) return;

        setState(() {
          _focusedDay = newDate;
          _selectedDay = DateTime(year, month, 1);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay ?? _focusedDay;
    final events = controller.getEvents(selected);

    final bool canGoPrev = !(_focusedDay.year == _minDate.year && _focusedDay.month == _minDate.month);
    final bool canGoNext = !(_focusedDay.year == _maxDate.year && _focusedDay.month == _maxDate.month);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ScheduleHeader(
            focusedDay: _focusedDay,
            onLeft: canGoPrev
                ? () => setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month - 1,
                      );
                    })
                : null,
            onRight: canGoNext
                ? () => setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month + 1,
                      );
                    })
                : null,
            onTapMonth: _showMonthPicker,
          ),
          ScheduleCalendar(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: _onDayTapped,
            onPageChanged: (d) => setState(() => _focusedDay = d),
            controller: controller,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: EventList(events: events, onEdit: _onEdit),
          ),
        ],
      ),
    );
  }
}
