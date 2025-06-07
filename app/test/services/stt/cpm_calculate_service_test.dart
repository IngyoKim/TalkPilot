import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:talk_pilot/src/services/database/cpm_history_service.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/utils/project/cpm_calculate_service.dart';

@GenerateNiceMocks([MockSpec<UserService>(), MockSpec<DatabaseService>()])
import 'cpm_calculate_service_test.mocks.dart';

void main() {
  late CpmCalculateService service;
  late MockUserService mockUserService;
  late MockDatabaseService mockDatabaseService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  const testUid = 'user_test';

  setUp(() {
    mockUserService = MockUserService();
    mockDatabaseService = MockDatabaseService();
    mockUser = MockUser(uid: testUid);
    mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser);

    CpmHistoryService.setMockDatabaseService(mockDatabaseService);

    service = CpmCalculateService(
      userService: mockUserService,
      databaseService: mockDatabaseService,
      firebaseAuth: mockFirebaseAuth,
    );
  });

  tearDown(() {
    CpmHistoryService.clearMockDatabaseService();
  });

  test('initial state is correct', () {
    expect(service.stage, CpmStage.ready);
    expect(service.currentSentence, isNotEmpty);
    expect(service.isLast, isFalse);
  });

  test('state transitions correctly through timing and finished', () async {
    service.onButtonPressed(MockBuildContext());
    expect(service.stage, CpmStage.timing);

    await Future.delayed(const Duration(milliseconds: 100));
    service.onButtonPressed(MockBuildContext());
    expect(service.stage, CpmStage.finished);
    expect(service.cpmResult, isNotNull);

    service.onButtonPressed(MockBuildContext());
    expect(service.stage, CpmStage.ready);
    expect(service.isLast, isFalse);
  });

  test('isLast becomes true on last sentence', () {
    while (!service.isLast) {
      service.onButtonPressed(MockBuildContext());
      service.onButtonPressed(MockBuildContext());
      service.onButtonPressed(MockBuildContext());
    }

    expect(service.isLast, isTrue);
  });
}

// 간단한 MockBuildContext (Navigator.pop 호출 방지용)
class MockBuildContext extends Fake implements BuildContext {}
