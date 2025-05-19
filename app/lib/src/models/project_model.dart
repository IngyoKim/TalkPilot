import 'package:talk_pilot/src/models/script_part_model.dart';

/// 변경 가능한 필드들만 정의
enum ProjectField {
  title,
  description,
  ownerUid,
  participants,
  status,
  estimatedTime,
  score,
  script,
  scheduledDate,
  memo,
  scriptPart,
}

extension ProjectFieldExt on ProjectField {
  String get key => toString().split('.').last;
}

/// 역할 정의
enum ProjectRole { owner, editor, member }

extension ProjectRoleExtension on ProjectRole {
  bool get canEdit => this == ProjectRole.owner || this == ProjectRole.editor;
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
  final String? script; // 대본
  final DateTime? scheduledDate; // 발표 일자
  final String? memo; // 메모
  final List<ScriptPartModel>? scriptParts;

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
    this.script,
    this.scheduledDate,
    this.memo,
    this.scriptParts,
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
              : 0,
      score: map['score'] != null ? (map['score'] as num).toDouble() : 0.0,
      script: map['script'] ?? '',
      scheduledDate:
          map['scheduledDate'] != null
              ? DateTime.tryParse(map['scheduledDate'])
              : null,
      memo: map['memo'] ?? '',
      scriptParts:
          map['scriptParts'] != null
              ? List<Map<String, dynamic>>.from(
                map['scriptParts'],
              ).map((e) => ScriptPartModel.fromMap(e)).toList()
              : null,
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
      if (script != null) "script": script,
      if (scheduledDate != null)
        "scheduledDate": scheduledDate!.toIso8601String(),
      if (memo != null) "memo": memo,
      if (scriptParts != null)
        "scriptParts": scriptParts!.map((e) => e.toMap()).toList(),
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
    String? script,
    DateTime? scheduledDate,
    String? memo,
    List<ScriptPartModel>? scriptParts,
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
      script: script ?? this.script,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      memo: memo ?? this.memo,
      scriptParts: scriptParts ?? this.scriptParts,
    );
  }
}
