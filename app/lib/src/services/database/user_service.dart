import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';

class UserService {
  final _db = DatabaseService();

  Future<void> writeUser(UserModel user, {bool onlyIfAbsent = false}) async {
    if (onlyIfAbsent) {
      final existing = await readUser(user.uid);
      if (existing != null) return;
    }
    await _db.writeDB("users/${user.uid}", user.toMap());
  }

  Future<UserModel?> readUser(String uid) async {
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

  /// FirebaseAuth 유저로부터 UserModel 생성 + 저장 (초기화 전용)
  Future<void> initUserFromAuth(
    User firebaseUser, {
    String? loginMethod,
  }) async {
    final providerInfo =
        firebaseUser.providerData.isNotEmpty
            ? firebaseUser.providerData.first
            : null;

    final userModel = UserModel(
      uid: firebaseUser.uid,
      name: providerInfo?.displayName ?? firebaseUser.displayName ?? '',
      email: providerInfo?.email ?? firebaseUser.email ?? '',
      nickname: providerInfo?.displayName ?? firebaseUser.displayName ?? '',
      photoUrl: providerInfo?.photoURL ?? firebaseUser.photoURL,
      loginMethod: loginMethod,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),

      // 기본값 설정
      averageScore: 0.0,
      targetScore: 90.0,
      projectStatuses: {}, // 빈 Map으로 초기화
    );

    await writeUser(userModel, onlyIfAbsent: true);
  }
}
