import 'package:flutter/material.dart';

//일정(Event) 모델 정의
class Event {
  final String title;
  final Color color;

  Event({required this.title, required this.color});

  static const List<Color> colorOptions = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];
}
