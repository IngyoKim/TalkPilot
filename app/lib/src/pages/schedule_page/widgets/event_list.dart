import 'package:flutter/material.dart';
import 'package:talk_pilot/src/pages/schedule_page/utils/event.dart';

//저장된 일정 리스트 UI
class EventList extends StatelessWidget {
  final List<Event> events;
  final void Function(int index, Event event) onEdit;

  const EventList({super.key, required this.events, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('저장된 일정:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...events.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: e.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(e.title, style: const TextStyle(fontSize: 16)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => onEdit(i, e),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
