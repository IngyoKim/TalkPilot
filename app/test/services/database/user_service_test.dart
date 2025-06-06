import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

@GenerateMocks([DatabaseService, User])
import 'user_service_test.mocks.dart';

void main() {
  late MockDatabaseService mockDatabaseService;
  late UserService userService;

  const testUid = 'testUid';

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    userService = UserService(databaseService: mockDatabaseService);
;
  });

  test('writeUser writes data when onlyIfAbsent is false', () async {
    final user = UserModel(
      uid: testUid,
      name: 'Test User',
      email: 'test@example.com',
      nickname: 'test_nickname',
    );

    when(mockDatabaseService.writeDB(any, any)).thenAnswer((_) async {});

    await userService.writeUser(user);

    verify(
      mockDatabaseService.writeDB('users/$testUid', user.toMap()),
    ).called(1);
  });

  test(
    'writeUser skips writing if user exists and onlyIfAbsent is true',
    () async {
      final user = UserModel(
        uid: testUid,
        name: 'Test User',
        email: 'test@example.com',
        nickname: 'test_nickname',
      );

      when(
        mockDatabaseService.readDB<Map<String, dynamic>>(any),
      ).thenAnswer((_) async => {'name': 'Existing User'});

      await userService.writeUser(user, onlyIfAbsent: true);

      verifyNever(mockDatabaseService.writeDB(any, any));
    },
  );

  test('readUser returns UserModel when data exists', () async {
    final map = {'name': 'Test User'};
    when(
      mockDatabaseService.readDB<Map<String, dynamic>>(any),
    ).thenAnswer((_) async => map);

    final result = await userService.readUser(testUid);

    expect(result, isA<UserModel>());
    expect(result?.name, 'Test User');
  });

  test('readUser returns null when no data', () async {
    when(
      mockDatabaseService.readDB<Map<String, dynamic>>(any),
    ).thenAnswer((_) async => null);

    final result = await userService.readUser(testUid);

    expect(result, isNull);
  });

  test('updateUser updates data with updatedAt field', () async {
    when(mockDatabaseService.updateDB(any, any)).thenAnswer((_) async {});

    await userService.updateUser(testUid, {'name': 'Updated User'});

    verify(
      mockDatabaseService.updateDB(
        'users/$testUid',
        argThat(
          allOf(containsPair('name', 'Updated User'), contains('updatedAt')),
        ),
      ),
    ).called(1);
  });

  test('deleteUser deletes user data', () async {
    when(mockDatabaseService.deleteDB(any)).thenAnswer((_) async {});

    await userService.deleteUser(testUid);

    verify(mockDatabaseService.deleteDB('users/$testUid')).called(1);
  });

  test('initUser writes new user if not exists', () async {
    final mockFirebaseUser = MockUser();
    when(mockFirebaseUser.uid).thenReturn(testUid);
    when(mockFirebaseUser.providerData).thenReturn([]);
    when(mockFirebaseUser.displayName).thenReturn('Firebase User');
    when(mockFirebaseUser.email).thenReturn('firebase@example.com');
    when(mockFirebaseUser.photoURL).thenReturn('http://photo.url');

    when(
      mockDatabaseService.readDB<Map<String, dynamic>>(any),
    ).thenAnswer((_) async => null);
    when(mockDatabaseService.writeDB(any, any)).thenAnswer((_) async {});

    await userService.initUser(mockFirebaseUser, loginMethod: 'google');

    verify(
      mockDatabaseService.writeDB(
        'users/$testUid',
        argThat(containsPair('loginMethod', 'google')),
      ),
    ).called(1);
  });

  test('initUser updates only missing fields for existing user', () async {
    final mockFirebaseUser = MockUser();
    when(mockFirebaseUser.uid).thenReturn(testUid);
    when(mockFirebaseUser.providerData).thenReturn([]);
    when(mockFirebaseUser.displayName).thenReturn('Firebase User');
    when(mockFirebaseUser.email).thenReturn('firebase@example.com');
    when(mockFirebaseUser.photoURL).thenReturn('http://photo.url');

    when(
      mockDatabaseService.readDB<Map<String, dynamic>>(any),
    ).thenAnswer((_) async => {'name': 'Existing User', 'nickname': 'Nick'});

    when(mockDatabaseService.updateDB(any, any)).thenAnswer((_) async {});

    await userService.initUser(mockFirebaseUser, loginMethod: 'google');

    verify(
      mockDatabaseService.updateDB(
        'users/$testUid',
        argThat(isA<Map<String, dynamic>>()),
      ),
    ).called(1);
  });
}