class UserModel {
  final String uid;
  final String name;
  final String email;
  final String nickname;
  final String? photoUrl;
  final String? loginMethod; // 이름 변경
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, String>? projectStatuses; // 상태 매핑된 프로젝트 목록
  final double? averageScore;
  final double? targetScore;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.nickname,
    this.photoUrl,
    this.loginMethod,
    this.createdAt,
    this.updatedAt,
    this.projectStatuses,
    this.averageScore,
    this.targetScore,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      nickname: map['nickname'] ?? '',
      photoUrl: map['photoUrl'],
      loginMethod: map['loginMethod'],
      createdAt:
          map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      projectStatuses:
          map['projectStatuses'] != null
              ? Map<String, String>.from(map['projectStatuses'])
              : null,
      averageScore:
          map['averageScore'] != null
              ? (map['averageScore'] as num).toDouble()
              : null,
      targetScore:
          map['targetScore'] != null
              ? (map['targetScore'] as num).toDouble()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "nickname": nickname,
      if (photoUrl != null) "photoUrl": photoUrl,
      if (loginMethod != null) "loginMethod": loginMethod,
      if (createdAt != null) "createdAt": createdAt!.toIso8601String(),
      if (updatedAt != null) "updatedAt": updatedAt!.toIso8601String(),
      if (projectStatuses != null) "projectStatuses": projectStatuses,
      if (averageScore != null) "averageScore": averageScore,
      if (targetScore != null) "targetScore": targetScore,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? nickname,
    String? photoUrl,
    String? loginMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, String>? projectStatuses,
    double? averageScore,
    double? targetScore,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      photoUrl: photoUrl ?? this.photoUrl,
      loginMethod: loginMethod ?? this.loginMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projectStatuses: projectStatuses ?? this.projectStatuses,
      averageScore: averageScore ?? this.averageScore,
      targetScore: targetScore ?? this.targetScore,
    );
  }
}
