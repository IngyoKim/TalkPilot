import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';

class UserService {
  final _db = DatabaseService();

  Future<void> saveUser(UserModel user) async {
    await _db.writeDB("users/${user.uid}", user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final map = await _db.readDB<Map<String, dynamic>>("users/$uid");
    if (map == null) return null;
    return UserModel.fromMap(uid, map);
  }

  Future<void> updateUser(UserModel user) async {
    await _db.updateDB("users/${user.uid}", user.toMap());
  }

  Future<void> deleteUser(String uid) async {
    await _db.deleteDB("users/$uid");
  }
}
