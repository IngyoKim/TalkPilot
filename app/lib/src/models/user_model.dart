class UserModel {
  final String uid;
  final String name;
  final String email;
  final String nickname;
  final String? photoUrl;
  final String? loginProvider;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? projectIds;
  final double? averageScore; // 평균 발표 점수
  final double? targetScore; // 목표 점수

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.nickname,
    this.photoUrl,
    this.loginProvider,
    this.createdAt,
    this.updatedAt,
    this.projectIds,
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
      loginProvider: map['loginProvider'],
      createdAt:
          map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      projectIds:
          map['projectIds'] != null ? List<String>.from(map['projectIds']) : [],
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
      if (loginProvider != null) "loginProvider": loginProvider,
      if (createdAt != null) "createdAt": createdAt!.toIso8601String(),
      if (updatedAt != null) "updatedAt": updatedAt!.toIso8601String(),
      if (projectIds != null) "projectIds": projectIds,
      if (averageScore != null) "averageScore": averageScore,
      if (targetScore != null) "targetScore": targetScore,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? nickname,
    String? photoUrl,
    String? loginProvider,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? projectIds,
    double? averageScore,
    double? targetScore,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      photoUrl: photoUrl ?? this.photoUrl,
      loginProvider: loginProvider ?? this.loginProvider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      projectIds: projectIds ?? this.projectIds,
      averageScore: averageScore ?? this.averageScore,
      targetScore: targetScore ?? this.targetScore,
    );
  }
}
