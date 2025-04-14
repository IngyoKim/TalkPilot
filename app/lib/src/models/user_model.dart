class UserModel {
  final String uid;
  final String name;
  final String email;
  final String nickname;
  final String? photoUrl;
  final String? loginMethod;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, String>? projectIds;
  final double? averageScore;
  final double? targetScore;
  final double? cpm;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.nickname,
    this.photoUrl,
    this.loginMethod,
    this.createdAt,
    this.updatedAt,
    this.projectIds,
    this.averageScore,
    this.targetScore,
    this.cpm,
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
      projectIds:
          map['projectIds'] != null
              ? Map<String, String>.from(map['projectIds'])
              : null,
      averageScore:
          map['averageScore'] != null
              ? (map['averageScore'] as num).toDouble()
              : null,
      targetScore:
          map['targetScore'] != null
              ? (map['targetScore'] as num).toDouble()
              : null,
      cpm: map['cpm'] != null ? (map['cpm'] as num).toDouble() : null,
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
      if (projectIds != null) "projectIds": projectIds,
      if (averageScore != null) "averageScore": averageScore,
      if (targetScore != null) "targetScore": targetScore,
      if (cpm != null) "cpm": cpm,
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
    Map<String, String>? projectIds,
    double? averageScore,
    double? targetScore,
    double? cpm,
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
      projectIds: projectIds ?? this.projectIds,
      averageScore: averageScore ?? this.averageScore,
      targetScore: targetScore ?? this.targetScore,
      cpm: cpm ?? this.cpm,
    );
  }
}
