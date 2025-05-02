import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, String> _events = {};
  final TextEditingController _eventController = TextEditingController();
  bool _isInputVisible = false;

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay ?? _focusedDay;
    final savedEvent = _events[selected];

    return Scaffold(
      appBar: AppBar(
        title: const Text('스케줄', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _eventController.text = _events[selectedDay] ?? '';
                _isInputVisible = false;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
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
          // 일정 생성 버튼
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isInputVisible = !_isInputVisible;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _eventController,
                    decoration: const InputDecoration(
                      labelText: '일정 입력',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedDay != null && _eventController.text.isNotEmpty) {
                        setState(() {
                          _events[_selectedDay!] = _eventController.text.trim();
                          _isInputVisible = false;
                        });
                      }
                    },
                    child: const Text('완료'),
                  ),
                ],
              ),
            ),
          if (savedEvent != null && savedEvent.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('저장된 일정:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(savedEvent),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
