class CpmRecordModel {
  final double cpm;
  final DateTime timestamp;

  CpmRecordModel({required this.cpm, required this.timestamp});

  factory CpmRecordModel.fromMap(Map<String, dynamic> map) => CpmRecordModel(
    cpm: (map['cpm'] as num).toDouble(),
    timestamp: DateTime.parse(map['timestamp']),
  );

  Map<String, dynamic> toMap() => {
    'cpm': cpm,
    'timestamp': timestamp.toIso8601String(),
  };

  Map<String, dynamic> toJson() => toMap();
}
