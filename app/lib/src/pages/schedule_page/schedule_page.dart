import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:talk_pilot/src/pages/schedule_page/components/schedule_calendar.dart';
import 'package:talk_pilot/src/pages/schedule_page/components/schedule_event_editor.dart';
import 'package:talk_pilot/src/pages/schedule_page/components/schedule_header.dart';

import 'package:talk_pilot/src/pages/schedule_page/utils/event.dart';
import 'package:talk_pilot/src/pages/schedule_page/widgets/event_list.dart';
import 'package:talk_pilot/src/pages/schedule_page/widgets/schedule_controller.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final controller = ScheduleController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  bool _isInputVisible = false;
  int? _editingIndex;
  Color _selectedColor = Colors.red;

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
      setState(() {});
    }
  }

  void _onDayTapped(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = controller.normalize(selected);
      _focusedDay = focused;
      _isInputVisible = false;
      _editingIndex = null;
    });
  }

  void _onEdit(int index, Event event) {
    setState(() {
      _editingIndex = index;
      _selectedColor = event.color;
      _isInputVisible = true;
    });
  }

  Future<void> _updateColor() async {
    final day = _selectedDay;
    final index = _editingIndex;
    if (day == null || index == null) return;
    final events = controller.getEvents(day);
    if (index >= events.length) return;

    final old = events[index];
    final updated = Event(title: old.title, color: _selectedColor);
    await controller.saveColor(old.title, _selectedColor);

    setState(() {
      events[index] = updated;
      _isInputVisible = false;
      _editingIndex = null;
    });
  }

  void _showMonthPicker() {
    Event.showMonthYearPickerDialog(
      context: context,
      initialYear: _focusedDay.year,
      initialMonth: _focusedDay.month,
      onSelected: (year, month) {
        setState(() {
          _focusedDay = DateTime(year, month);
          _selectedDay = DateTime(year, month, 1);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay ?? _focusedDay;
    final events = controller.getEvents(selected);

    return Scaffold(
      appBar: AppBar(
        title: const Text('스케줄', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ScheduleHeader(
            focusedDay: _focusedDay,
            onLeft:
                () => setState(() {
                  _focusedDay = DateTime(
                    _focusedDay.year,
                    _focusedDay.month - 1,
                  );
                }),
            onRight:
                () => setState(() {
                  _focusedDay = DateTime(
                    _focusedDay.year,
                    _focusedDay.month + 1,
                  );
                }),
            onTapMonth: _showMonthPicker,
          ),
          ScheduleCalendar(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: _onDayTapped,
            onPageChanged: (d) => setState(() => _focusedDay = d),
            controller: controller,
          ),
          if (_isInputVisible)
            ScheduleEventEditor(
              selectedColor: _selectedColor,
              onColorChanged: (color) => setState(() => _selectedColor = color),
              onSave: _updateColor,
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
