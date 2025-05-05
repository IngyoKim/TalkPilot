import 'package:flutter/material.dart';
import 'package:talk_pilot/src/pages/schedule_page/components/schedule_color_picker.dart';

class ScheduleEventEditor extends StatelessWidget {
  final Color selectedColor;
  final void Function(Color) onColorChanged;
  final VoidCallback onSave;

  const ScheduleEventEditor({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        children: [
          ScheduleColorPicker(
            selectedColor: selectedColor,
            onColorChanged: onColorChanged,
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onSave, child: const Text('색상 수정')),
        ],
      ),
    );
  }
}
