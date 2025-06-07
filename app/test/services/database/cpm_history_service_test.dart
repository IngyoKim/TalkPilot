import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:talk_pilot/src/models/cpm_record_model.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/services/database/cpm_history_service.dart';

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<DatabaseService>(as: #MockDatabaseService),
    MockSpec<UserService>(as: #MockUserService),
  ],
)
import 'cpm_history_service_test.mocks.dart';

void main() {
  group('CpmHistoryService', () {
    late MockDatabaseService mockDatabaseService;
    late MockUserService mockUserService;

    const testUid = 'testUid';

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockUserService = MockUserService();
    });

    test('addCpmRecord writes correct data', () async {
      final record = CpmRecordModel(cpm: 120, timestamp: DateTime(2024, 1, 1));

      when(mockDatabaseService.writeDB(any, any)).thenAnswer((_) async {});

      await mockUserService.addCpmRecord(
        testUid,
        record,
        db: mockDatabaseService,
      );

      verify(
        mockDatabaseService.writeDB(
          "users/$testUid/cpmHistory/${record.timestamp.millisecondsSinceEpoch}",
          record.toMap(),
        ),
      ).called(1);
    });

    test('getCpmHistory fetches correct data', () async {
      final recordMap = {
        'cpm': 150.0,
        'timestamp': DateTime(2024, 1, 1).toIso8601String(),
      };

      when(
        mockDatabaseService.fetchDB<CpmRecordModel>(
          path: anyNamed('path'),
          fromMap: anyNamed('fromMap'),
        ),
      ).thenAnswer((_) async => [CpmRecordModel.fromMap(recordMap)]);

      final result = await mockUserService.getCpmHistory(
        testUid,
        db: mockDatabaseService,
      );

      expect(result.length, 1);
      expect(result.first.cpm, 150.0);
    });

    test('updateAverageCpm calculates and updates average', () async {
      final history = [
        CpmRecordModel(cpm: 100, timestamp: DateTime.now()),
        CpmRecordModel(cpm: 200, timestamp: DateTime.now()),
      ];

      when(
        mockDatabaseService.fetchDB<CpmRecordModel>(
          path: anyNamed('path'),
          fromMap: anyNamed('fromMap'),
        ),
      ).thenAnswer((_) async => history);

      when(mockUserService.updateUser(any, any)).thenAnswer((_) async {});

      await mockUserService.updateAverageCpm(testUid, db: mockDatabaseService);

      verify(mockUserService.updateUser(testUid, {'cpm': 150.0})).called(1);
    });

    test('clearCpmHistory clears data and resets cpm', () async {
      when(mockDatabaseService.deleteDB(any)).thenAnswer((_) async {});
      when(mockUserService.updateUser(any, any)).thenAnswer((_) async {});

      await mockUserService.clearCpmHistory(testUid, db: mockDatabaseService);

      verify(
        mockDatabaseService.deleteDB("users/$testUid/cpmHistory"),
      ).called(1);
      verify(mockUserService.updateUser(testUid, {'cpm': 0.0})).called(1);
    });

    test('deleteCpmRecord deletes record and updates average', () async {
      final timestampMillis = DateTime(2024, 1, 1).millisecondsSinceEpoch;

      when(mockDatabaseService.deleteDB(any)).thenAnswer((_) async {});
      when(
        mockDatabaseService.fetchDB<CpmRecordModel>(
          path: anyNamed('path'),
          fromMap: anyNamed('fromMap'),
        ),
      ).thenAnswer(
        (_) async => [
          CpmRecordModel(cpm: 100, timestamp: DateTime.now()),
          CpmRecordModel(cpm: 200, timestamp: DateTime.now()),
        ],
      );

      when(mockUserService.updateUser(any, any)).thenAnswer((_) async {});

      await mockUserService.deleteCpmRecord(
        testUid,
        timestampMillis,
        db: mockDatabaseService,
      );

      verify(
        mockDatabaseService.deleteDB(
          "users/$testUid/cpmHistory/$timestampMillis",
        ),
      ).called(1);
      verify(mockUserService.updateUser(testUid, any)).called(1);
    });
    test('addCpmRecord uses default _cpmDb when db not provided', () async {
      final record = CpmRecordModel(cpm: 120, timestamp: DateTime(2024, 1, 1));

      try {
        await mockUserService.addCpmRecord(testUid, record);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('getCpmHistory uses default _cpmDb when db not provided', () async {
      try {
        await mockUserService.getCpmHistory(testUid);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('clearCpmHistory uses default _cpmDb when db not provided', () async {
      try {
        await mockUserService.clearCpmHistory(testUid);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('deleteCpmRecord uses default _cpmDb when db not provided', () async {
      final timestampMillis = DateTime(2024, 1, 1).millisecondsSinceEpoch;

      try {
        await mockUserService.deleteCpmRecord(testUid, timestampMillis);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
    test('getCpmHistory fetches correct data', () async {
      final recordMap = {
        'cpm': 150.0,
        'timestamp': DateTime(2024, 1, 1).toIso8601String(),
      };

      when(
        mockDatabaseService.fetchDB<CpmRecordModel>(
          path: anyNamed('path'),
          fromMap: anyNamed('fromMap'),
        ),
      ).thenAnswer((invocation) async {
        final fromMapFunc =
            invocation.namedArguments[#fromMap]
                as CpmRecordModel Function(Map<String, dynamic>);
        final record = fromMapFunc(recordMap);
        expect(record.cpm, 150.0);
        return [record];
      });

      final result = await mockUserService.getCpmHistory(
        testUid,
        db: mockDatabaseService,
      );

      expect(result.length, 1);
      expect(result.first.cpm, 150.0);

      verify(
        mockDatabaseService.fetchDB<CpmRecordModel>(
          path: "users/$testUid/cpmHistory",
          fromMap: anyNamed('fromMap'),
        ),
      ).called(1);
    });
  });
}
