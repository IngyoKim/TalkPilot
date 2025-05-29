String formatEstimatedTime(double? seconds) {
  if (seconds == null || seconds <= 0) return '없음';
  final min = seconds ~/ 60;
  final sec = (seconds % 60).round();
  return '$min분 $sec초';
}