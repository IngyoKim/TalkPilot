import 'package:flutter/material.dart';

class ScheduleHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onTapMonth;

  const ScheduleHeader({
    super.key,
    required this.focusedDay,
    required this.onLeft,
    required this.onRight,
    required this.onTapMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onLeft),
          GestureDetector(
            onTap: onTapMonth,
            child: Text(
              '${focusedDay.year}년 ${focusedDay.month}월',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onRight),
        ],
      ),
    );
  }
}
