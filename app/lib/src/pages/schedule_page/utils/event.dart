import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  static const List<String> monthAbbr = [
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

  static void showMonthYearPickerDialog({
    required BuildContext context,
    required int initialYear,
    required int initialMonth,
    required void Function(int year, int month) onSelected,
  }) {
    int tempYear = initialYear;
    int tempMonth = initialMonth;

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
                                '${monthAbbr[index]}월',
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
                    onSelected(tempYear, tempMonth);
                  },
                ),
              ],
            ),
          ),
    );
  }
}
