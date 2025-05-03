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
  // 일정 데이터를 저장하는 맵 (날짜별 이벤트 리스트)
  final Map<DateTime, List<Event>> _events = {};

  // 입력 필드 컨트롤러
  final TextEditingController _controller = TextEditingController();

  // 현재 보고 있는 날짜와 선택된 날짜
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // 입력창 표시 여부, 수정 중인 인덱스, 선택된 색상
  bool _isInputVisible = false;
  int? _editingIndex;
  Color _selectedColor = Colors.red;

  // 날짜 객체를 날짜만 남기고 정규화
  DateTime _normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // 특정 날짜의 이벤트 가져오기
  List<Event> _getEvents(DateTime day) => _events[_normalize(day)] ?? [];

  // 일정 입력창 열기 (수정 시 기존 값 불러오기)
  void _toggleInput({int? editIndex, Event? event}) {
    setState(() {
      _isInputVisible = true;
      _editingIndex = editIndex;
      _controller.text = event?.title ?? '';
      _selectedColor = event?.color ?? Colors.blue;
    });
  }

  // 일정 저장 (신규 또는 수정)
  void _saveEvent() {
    final text = _controller.text.trim();
    if (text.isEmpty || _selectedDay == null) return;

    final day = _normalize(_selectedDay!);
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

  // 일정 삭제
  void _deleteEvent(int index) {
    final day = _normalize(_selectedDay!);
    setState(() {
      _events[day]!.removeAt(index);
      if (_events[day]!.isEmpty) _events.remove(day);
    });
  }

  // 헤더 탭 시 연도/월 선택 다이얼로그 열기
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

  // 커스텀 캘린더 헤더 (연도/월 및 좌우 화살표)
  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 이전 달 이동
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
              });
            },
          ),
          // 연도/월 표시 및 선택
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
          // 다음 달 이동
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
      body: Column(
        children: [
          // 커스텀 헤더 (월/연도 표시 및 이동)
          _buildCustomHeader(),

          // 메인 캘린더 위젯
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
              markerBuilder: (context, date, _) {
                final eventList = _getEvents(date);
                if (eventList.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Wrap(
                    spacing: 2,
                    children:
                        eventList.take(4).map((e) {
                          return Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: e.color,
                              shape: BoxShape.circle,
                            ),
                          );
                        }).toList(),
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

          // 일정 생성 버튼
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

          // 일정 입력 폼
          if (_isInputVisible)
            EventInputForm(
              controller: _controller,
              selectedColor: _selectedColor,
              onColorChanged: (color) => setState(() => _selectedColor = color),
              colorOptions: Event.colorOptions,
              isEditing: _editingIndex != null,
              onSave: _saveEvent,
            ),

          // 저장된 일정 리스트 출력
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
