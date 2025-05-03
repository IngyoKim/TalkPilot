import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:talk_pilot/src/pages/schedule_page/widgets/event.dart';
import 'package:talk_pilot/src/pages/schedule_page/widgets/event_input_form.dart';
import 'package:talk_pilot/src/pages/schedule_page/widgets/event_list.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final Map<DateTime, List<Event>> _events = {};
  final TextEditingController _controller = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _isInputVisible = false;
  int? _editingIndex;
  Color _selectedColor = Colors.red;

  DateTime _normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  List<Event> _getEvents(DateTime day) => _events[_normalize(day)] ?? [];

  void _toggleInput({int? editIndex, Event? event}) {
    setState(() {
      _isInputVisible = true;
      _editingIndex = editIndex;
      _controller.text = event?.title ?? '';
      _selectedColor = event?.color ?? Colors.blue;
      _rangeStart = null;
      _rangeEnd = null;
    });
  }

  void _saveEvent() {
    final text = _controller.text.trim();
    if (text.isEmpty || _selectedDay == null) return;

    final start = _normalize(_rangeStart ?? _selectedDay!);
    final end = _normalize(_rangeEnd ?? _selectedDay!);
    final newEvent = Event(title: text, color: _selectedColor);

    setState(() {
      for (
        var day = start;
        !day.isAfter(end);
        day = day.add(const Duration(days: 1))
      ) {
        _events.putIfAbsent(day, () => []).add(newEvent);
      }
      _controller.clear();
      _isInputVisible = false;
      _editingIndex = null;
      _rangeStart = null;
      _rangeEnd = null;
    });
  }

  void _deleteEvent(int index) {
    final day = _normalize(_selectedDay!);
    setState(() {
      _events[day]!.removeAt(index);
      if (_events[day]!.isEmpty) _events.remove(day);
    });
  }

  void _onHeaderTapped() {
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

  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
              });
            },
          ),
          GestureDetector(
            onTap: _onHeaderTapped,
            child: Text(
              '${_focusedDay.year}년 ${_focusedDay.month}월',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _rangeStart = picked;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _rangeStart ?? _selectedDay ?? DateTime.now(),
      firstDate: _rangeStart ?? DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _rangeEnd = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay ?? _focusedDay;
    final savedEvents = _getEvents(selected);

    return Scaffold(
      appBar: AppBar(
        title: const Text('스케줄', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          _buildCustomHeader(),
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = _normalize(selectedDay);
                _focusedDay = focusedDay;
                _isInputVisible = false;
                _controller.clear();
                _editingIndex = null;
              });
            },
            headerVisible: false,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                final normalizedDate = _normalize(date);
                final hasEvent = _events.containsKey(normalizedDate);
                final eventList = _getEvents(normalizedDate);
                if (!hasEvent) return null;

                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: eventList.first.color,
                        width: 2,
                      ),
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
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8),
              child: GestureDetector(
                onTap: () => _toggleInput(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '일정 생성',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          if (_isInputVisible)
            Column(
              children: [
                EventInputForm(
                  controller: _controller,
                  selectedColor: _selectedColor,
                  onColorChanged:
                      (color) => setState(() => _selectedColor = color),
                  colorOptions: Event.colorOptions,
                  isEditing: _editingIndex != null,
                  onSave: _saveEvent,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _pickStartDate,
                      child: Text(
                        _rangeStart == null
                            ? '시작일 선택'
                            : '시작: ${_rangeStart!.year}.${_rangeStart!.month}.${_rangeStart!.day}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _pickEndDate,
                      child: Text(
                        _rangeEnd == null
                            ? '종료일 선택'
                            : '종료: ${_rangeEnd!.year}.${_rangeEnd!.month}.${_rangeEnd!.day}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          EventList(
            events: savedEvents,
            onEdit: (i, e) => _toggleInput(editIndex: i, event: e),
            onDelete: _deleteEvent,
          ),
        ],
      ),
    );
  }
}
