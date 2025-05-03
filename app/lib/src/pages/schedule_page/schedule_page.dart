import 'package:flutter/cupertino.dart';
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
  bool _isInputVisible = false;
  int? _editingIndex;
  Color _selectedColor = Colors.red;

  List<Event> _getEvents(DateTime day) => _events[day] ?? [];

  void _toggleInput({int? editIndex, Event? event}) {
    setState(() {
      _isInputVisible = true;
      _editingIndex = editIndex;
      _controller.text = event?.title ?? '';
      _selectedColor = event?.color ?? Colors.blue;
    });
  }

  void _saveEvent() {
    final text = _controller.text.trim();
    if (text.isEmpty || _selectedDay == null) return;

    final day = _selectedDay!;
    final newEvent = Event(title: text, color: _selectedColor);

    setState(() {
      if (_editingIndex != null) {
        _events[day]![_editingIndex!] = newEvent;
      } else {
        _events.putIfAbsent(day, () => []).add(newEvent);
      }
      _controller.clear();
      _isInputVisible = false;
      _editingIndex = null;
    });
  }

  void _deleteEvent(int index) {
    final day = _selectedDay!;
    setState(() {
      _events[day]!.removeAt(index);
      if (_events[day]!.isEmpty) _events.remove(day);
    });
  }

  void _showMonthYearPicker() {
    int tempYear = _focusedDay.year;
    int tempMonth = _focusedDay.month;

    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => Container(
            height: 300,
            color: Colors.white,
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: tempYear - 2025,
                          ),
                          itemExtent: 36.0,
                          onSelectedItemChanged: (index) {
                            tempYear = 2025 + index;
                          },
                          children: List.generate(11, (index) {
                            final year = 2025 + index;
                            return Center(
                              child: Text(
                                '$year년',
                                style: const TextStyle(fontSize: 18),
                              ),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: tempMonth - 1,
                          ),
                          itemExtent: 36.0,
                          onSelectedItemChanged: (index) {
                            tempMonth = index + 1;
                          },
                          children: List.generate(12, (index) {
                            return Center(
                              child: Text(
                                '${_monthAbbr[index]}월',
                                style: const TextStyle(fontSize: 18),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoButton(
                  child: const Text('선택 완료'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _focusedDay = DateTime(tempYear, tempMonth);
                      _selectedDay = DateTime(tempYear, tempMonth, 1);
                    });
                  },
                ),
              ],
            ),
          ),
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
            onTap: _showMonthYearPicker,
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

  final List<String> _monthAbbr = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];

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
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _isInputVisible = false;
                _controller.clear();
                _editingIndex = null;
              });
            },
            headerVisible: false,
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
            EventInputForm(
              controller: _controller,
              selectedColor: _selectedColor,
              onColorChanged: (color) => setState(() => _selectedColor = color),
              colorOptions: Event.colorOptions,
              isEditing: _editingIndex != null,
              onSave: _saveEvent,
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
