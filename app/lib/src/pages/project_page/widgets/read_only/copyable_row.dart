import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talk_pilot/src/components/toast_message.dart';

class CopyableRow extends StatelessWidget {
  final String label;
  final String value;

  const CopyableRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: SelectableText(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ToastMessage.show("프로젝트 ID가 복사되었습니다");
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.copy, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
