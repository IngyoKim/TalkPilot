import 'package:flutter/material.dart';

//일정 입력/수정 위젯
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
            children:
                colorOptions.map((color) {
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
