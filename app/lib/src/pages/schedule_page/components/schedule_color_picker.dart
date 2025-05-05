import 'package:flutter/material.dart';
import 'package:talk_pilot/src/pages/schedule_page/utils/event.dart';

class ScheduleColorPicker extends StatelessWidget {
  final Color selectedColor;
  final void Function(Color) onColorChanged;

  const ScheduleColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children:
          Event.colorOptions.map((color) {
            return GestureDetector(
              onTap: () => onColorChanged(color),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border:
                      selectedColor == color
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                ),
              ),
            );
          }).toList(),
    );
  }
}
