import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'preparing':
      return const Color(0xFF4CAF50);
    case 'paused':
      return const Color(0xFFFFEB3B);
    case 'completed':
      return const Color(0xFFF44336);
    default:
      return const Color(0xFF4CAF50);
  }
}

String formatElapsedTime(DateTime createdAt) {
  final now = DateTime.now();
  final difference = now.difference(createdAt);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds}초 전';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}분 전';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}시간 전';
  } else {
    return '${difference.inDays}일 전';
  }
}
