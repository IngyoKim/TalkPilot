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
    };
  }
}
