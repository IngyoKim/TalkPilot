import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:talk_pilot/src/pages/schedule_page/widgets/schedule_controller.dart';

import 'widgets/event.dart';
import 'widgets/event_list.dart';

class SchedulePage extends StatefulWidget {
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ScheduleController controller = ScheduleController();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  bool _isInputVisible = false;
  int? _editingIndex;
  Color _selectedColor = Colors.red;

  DateTime _normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
  List<Event> _getEvents(DateTime day) => controller.getEvents(day);

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

  void _toggleColorEdit(int index, Event event) {
    setState(() {
      _isInputVisible = true;
      _editingIndex = index;
      _selectedColor = event.color;
    });
  }

  Future<void> _updateColorOnly() async {
    if (_selectedDay == null || _editingIndex == null) return;

    final day = _normalize(_selectedDay!);
    final events = controller.events[day];
    if (events == null || _editingIndex! >= events.length) return;

    final oldEvent = events[_editingIndex!];
    final newEvent = Event(title: oldEvent.title, color: _selectedColor);

    await controller.saveColor(oldEvent.title, _selectedColor);

    setState(() {
      events[_editingIndex!] = newEvent;
      _isInputVisible = false;
      _editingIndex = null;
      _focusedDay = _focusedDay.add(const Duration());
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

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay ?? _focusedDay;
    final savedEvents = _getEvents(selected);

    return Scaffold(
      appBar: AppBar(
        title: const Text('스케줄', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _buildCustomHeader(),
          TableCalendar(
            key: ValueKey(_focusedDay),
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = _normalize(selectedDay);
                _focusedDay = focusedDay;
                _isInputVisible = false;
                _editingIndex = null;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            headerVisible: false,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                final normalizedDate = _normalize(date);
                final hasEvent = controller.events.containsKey(normalizedDate);
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
          if (_isInputVisible)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
              child: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    children:
                        Event.colorOptions.map((color) {
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = color),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border:
                                    _selectedColor == color
                                        ? Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        )
                                        : null,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _updateColorOnly,
                    child: const Text('색상 수정'),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: EventList(events: savedEvents, onEdit: _toggleColorEdit),
          ),
        ],
      ),
    );
  }
}
