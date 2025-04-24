/// 변경 가능한 필드들만 정의
enum ProjectField {
  title,
  description,
  ownerUid,
  participants,
  status,
  estimatedTime,
  score,
}

extension ProjectFieldExt on ProjectField {
  String get key => toString().split('.').last;
}

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String ownerUid;
  final Map<String, String> participants; // "uid : role" 형식으로 저장장
  final String status; // e.g. "preparing", "completed"
  final int? estimatedTime; // 발표 예상 시간 (단위: 초)
  final double? score; // 프로젝트 점수

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    this.createdAt,
    this.updatedAt,
    required this.ownerUid,
    required this.participants,
    required this.status,
    this.estimatedTime,
    this.score,
  });

  factory ProjectModel.fromMap(String id, Map<String, dynamic> map) {
    return ProjectModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt:
          map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      ownerUid: map['ownerUid'] ?? '',
      participants:
          map['participants'] != null
              ? Map<String, String>.from(map['participants'])
              : {},
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
      "title": title,
      "description": description,
      if (createdAt != null) "createdAt": createdAt!.toIso8601String(),
      if (updatedAt != null) "updatedAt": updatedAt!.toIso8601String(),
      "ownerUid": ownerUid,
      "participants": participants,
      "status": status,
      if (estimatedTime != null) "estimatedTime": estimatedTime,
      if (score != null) "score": score,
    };
  }

  ProjectModel copyWith({
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerUid,
    Map<String, String>? participants,
    String? status,
    int? estimatedTime,
    double? score,
  }) {
    return ProjectModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerUid: ownerUid ?? this.ownerUid,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      score: score ?? this.score,
    );
  }
}
