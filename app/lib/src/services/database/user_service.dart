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

  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    final fullUpdates = {
      ...updates,
      'updatedAt': DateTime.now().toIso8601String(), // 자동으로 updateAt 갱신
    };
    await _db.updateDB("users/$uid", fullUpdates);
  }

  Future<void> deleteUser(String uid) async {
    await _db.deleteDB("users/$uid");
  }

  /// FirebaseAuth 유저로부터 UserModel 생성 + 저장 (초기화 전용)
  /// 유저 정보 중에서 누락된 필드가 있으면 자동으로 초기화
  Future<void> initUser(User firebaseUser, {String? loginMethod}) async {
    final existing = await readUser(firebaseUser.uid);

    final providerInfo =
        firebaseUser.providerData.isNotEmpty
            ? firebaseUser.providerData.first
            : null;

    final newFields = {
      'name': providerInfo?.displayName ?? firebaseUser.displayName ?? '',
      'email': providerInfo?.email ?? firebaseUser.email ?? '',
      'nickname': providerInfo?.displayName ?? firebaseUser.displayName ?? '',
      'photoUrl': providerInfo?.photoURL ?? firebaseUser.photoURL,
      'loginMethod': loginMethod,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'projectIds': {},
      'averageScore': 0.0,
      'targetScore': 70.0,
      'cpm': 0.0,
    };

    if (existing == null) {
      await _db.writeDB("users/${firebaseUser.uid}", newFields);
    } else {
      // 누락 필드만 채워 넣음
      final missingFields = <String, dynamic>{};
      newFields.forEach((key, value) {
        if (!(existing.toMap().containsKey(key))) {
          missingFields[key] = value;
        }
      });

      if (missingFields.isNotEmpty) {
        await updateUser(firebaseUser.uid, missingFields);
      }
    }
  }
}
