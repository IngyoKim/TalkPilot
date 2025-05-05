import 'package:flutter/material.dart';
import 'package:talk_pilot/src/pages/schedule_page/utils/event.dart';

Future<Color?> showColorDialog({
  required BuildContext context,
  required Color initialColor,
}) async {
  return showDialog<Color>(
    context: context,
    builder: (context) {
      Color selected = initialColor;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('색상 선택'),
            content: SizedBox(
              width: double.maxFinite,
              height: 150, // 고정 높이로 설정
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: selected,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12, width: 1),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: Event.colorOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final color = Event.colorOptions[i];
                        return GestureDetector(
                          onTap: () => setState(() => selected = color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    selected == color
                                        ? Colors.black
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    },
  );
}
