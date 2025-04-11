import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const StatRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
