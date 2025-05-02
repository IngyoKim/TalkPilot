import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// 모델 클래스
class Event {
  final String title;
  final Color color;

  Event({required this.title, required this.color});
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final Map<DateTime, List<Event>> _events = {};
  final TextEditingController _controller = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isInputVisible = false;
  int? _editingIndex;
  Color _selectedColor = Colors.blue;

  final List<Color> _colorOptions = [
    Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple
  ];

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
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
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
            headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.deepPurpleAccent, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8),
              child: GestureDetector(
                onTap: () => _toggleInput(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple, borderRadius: BorderRadius.circular(20)),
                  child: const Text('일정 생성', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ),
          if (_isInputVisible)
            EventInputForm(
              controller: _controller,
              selectedColor: _selectedColor,
              onColorChanged: (color) => setState(() => _selectedColor = color),
              colorOptions: _colorOptions,
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

// 일정 입력 폼 위젯
class EventInputForm extends StatelessWidget {
  final TextEditingController controller;
  final Color selectedColor;
  final List<Color> colorOptions;
  final bool isEditing;
  final VoidCallback onSave;
  final Function(Color) onColorChanged;

  const EventInputForm({
    super.key,
    required this.controller,
    required this.selectedColor,
    required this.colorOptions,
    required this.onSave,
    required this.onColorChanged,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: isEditing ? '일정 수정' : '일정 입력',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: colorOptions.map((color) {
              return GestureDetector(
                onTap: () => onColorChanged(color),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selectedColor == color
                        ? Border.all(color: Colors.black, width: 2)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onSave,
            child: Text(isEditing ? '수정 완료' : '완료'),
          ),
        ],
      ),
    );
  }
}

// 일정 리스트 출력 위젯
class EventList extends StatelessWidget {
  final List<Event> events;
  final void Function(int index, Event event) onEdit;
  final void Function(int index) onDelete;

  const EventList({
    super.key,
    required this.events,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('저장된 일정:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...events.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            return Row(
              children: [
                Container(
                  width: 10, height: 10,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(color: e.color, shape: BoxShape.circle),
                ),
                Expanded(child: Text(e.title)),
                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => onEdit(i, e)),
                IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: () => onDelete(i)),
              ],
            );
          }),
        ],
      ),
    );
  }
}
