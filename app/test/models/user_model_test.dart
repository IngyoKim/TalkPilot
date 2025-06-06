import 'package:flutter_test/flutter_test.dart';
import 'package:talk_pilot/src/models/user_model.dart';

void main() {
  group('UserModel', () {
    final now = DateTime.parse('2025-06-06T12:00:00.000Z');

    final map = {
      'name': 'John Doe',
      'email': 'john@example.com',
      'nickname': 'johnny',
      'photoUrl': 'http://example.com/photo.jpg',
      'loginMethod': 'google',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'projectIds': {'p1': 'owner', 'p2': 'member'},
      'averageScore': 88.5,
      'targetScore': 95.0,
      'cpm': 123.4,
    };

    test('fromMap creates valid UserModel', () {
      final user = UserModel.fromMap('abc123', map);

      expect(user.uid, 'abc123');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.nickname, 'johnny');
      expect(user.photoUrl, 'http://example.com/photo.jpg');
      expect(user.loginMethod, 'google');
      expect(user.createdAt, now);
      expect(user.updatedAt, now);
      expect(user.projectIds?['p1'], 'owner');
      expect(user.averageScore, 88.5);
      expect(user.targetScore, 95.0);
      expect(user.cpm, 123.4);
    });

    test('toMap returns correct map', () {
      final user = UserModel.fromMap('abc123', map);
      final result = user.toMap();

      expect(result['name'], 'John Doe');
      expect(result['email'], 'john@example.com');
      expect(result['nickname'], 'johnny');
      expect(result['photoUrl'], 'http://example.com/photo.jpg');
      expect(result['loginMethod'], 'google');
      expect(result['createdAt'], now.toIso8601String());
      expect(result['updatedAt'], now.toIso8601String());
      expect(result['projectIds'], {'p1': 'owner', 'p2': 'member'});
      expect(result['averageScore'], 88.5);
      expect(result['targetScore'], 95.0);
      expect(result['cpm'], 123.4);
    });

    test('copyWith overrides selected fields', () {
      final user = UserModel.fromMap('abc123', map);
      final updated = user.copyWith(name: 'Jane Doe', cpm: 150.0);

      expect(updated.name, 'Jane Doe');
      expect(updated.cpm, 150.0);
      expect(updated.email, user.email);
    });

    test('UserFieldExt.key returns correct key names', () {
      expect(UserField.email.key, 'email');
      expect(UserField.targetScore.key, 'targetScore');
    });
    test('copyWith retains original values when nulls are passed', () {
      final user = UserModel.fromMap('abc123', map);
      final copy = user.copyWith();

      expect(copy.name, user.name);
      expect(copy.cpm, user.cpm);
    });
  });
}
