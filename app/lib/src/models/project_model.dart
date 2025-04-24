class ProjectModel {
  final String id;
  final String name;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String ownerUid;
  final List<String> participantUids;
  final String status; // e.g. "preparing", "completed"
  final int? estimatedTime; // 발표 예상 시간 (단위: 초)
  final double? score; // 프로젝트 점수

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    this.createdAt,
    this.updatedAt,
    required this.ownerUid,
    required this.participantUids,
    required this.status,
    this.estimatedTime,
    this.score,
  });

  factory ProjectModel.fromMap(String id, Map<String, dynamic> map) {
    return ProjectModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdAt:
          map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      ownerUid: map['ownerUid'] ?? '',
      participantUids:
          map['participantUids'] != null
              ? List<String>.from(map['participantUids'])
              : [],
      status: map['status'] ?? 'preparing',
      estimatedTime:
          map['estimatedTime'] != null
              ? (map['estimatedTime'] as num).toInt()
              : null,
      score: map['score'] != null ? (map['score'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "description": description,
      if (createdAt != null) "createdAt": createdAt!.toIso8601String(),
      if (updatedAt != null) "updatedAt": updatedAt!.toIso8601String(),
      "ownerUid": ownerUid,
      "participantUids": participantUids,
      "status": status,
      if (estimatedTime != null) "estimatedTime": estimatedTime,
      if (score != null) "score": score,
    };
  }
}
