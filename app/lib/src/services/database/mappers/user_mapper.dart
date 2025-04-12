import 'package:talk_pilot/src/models/user_model.dart';

class UserMapper {
  static Map<String, dynamic> toMap(UserModel user) {
    return {"name": user.name, "email": user.email, "nickname": user.nickname};
  }

  static UserModel fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map["name"] ?? '',
      email: map["email"] ?? '',
      nickname: map["nickname"] ?? '',
    );
  }
}
