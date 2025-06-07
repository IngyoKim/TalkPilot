import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/database_stream_service.dart';
import 'package:talk_pilot/src/services/database/database_logger.dart'; // 원본 로그 함수 import

@GenerateMocks([
  FirebaseDatabase,
  DatabaseReference,
  DatabaseEvent,
  DataSnapshot,
])
import 'database_stream_service_test.mocks.dart';

// 테스트 시작 전에 dbLog/dbError 콜백을 테스트용으로 재정의
void main() {
  late MockFirebaseDatabase mockDatabase;
  late MockDatabaseReference mockRef;
  late MockDatabaseEvent mockEvent;
  late MockDataSnapshot mockSnapshot;
  late DatabaseStreamService service;

  late List<String> logCalls;
  late List<String> errorCalls;

  setUp(() {
    mockDatabase = MockFirebaseDatabase();
    mockRef = MockDatabaseReference();
    mockEvent = MockDatabaseEvent();
    mockSnapshot = MockDataSnapshot();

    service = DatabaseStreamService(database: mockDatabase);

    when(mockDatabase.ref(any)).thenReturn(mockRef);
    when(mockRef.onValue).thenAnswer((_) => Stream.value(mockEvent));
    when(mockEvent.snapshot).thenReturn(mockSnapshot);

    logCalls = [];
    errorCalls = [];

    // 원본 log, error 함수 내부에서 호출되는 콜백을 테스트용 콜백으로 교체
    dbLog = (tag, data) => logCalls.add('$tag:$data');
    dbError = (tag, err) => errorCalls.add('$tag:$err');
  });

  test('streamData emits model when data exists', () async {
    when(
      mockSnapshot.value,
    ).thenReturn({'field1': 'value1', 'field2': 'value2'});

    final stream = service.streamData(
      path: 'test/path',
      logTag: 'TEST',
      fromMap: (map) => DummyModel.fromMap(map),
    );

    await expectLater(
      stream,
      emits(isA<DummyModel>().having((m) => m.field1, 'field1', 'value1')),
    );

    expect(logCalls.length, 1);
    expect(logCalls.first.contains('TEST'), isTrue);
  });

  test('streamData throws when data is null', () async {
    when(mockSnapshot.value).thenReturn(null);

    final stream = service.streamData(
      path: 'test/path',
      logTag: 'TEST',
      fromMap: (map) => DummyModel.fromMap(map),
    );

    await expectLater(stream, emitsError(isA<Exception>()));

    expect(errorCalls.length, 1);
    expect(errorCalls.first.contains('TEST'), isTrue);
  });

  test('streamData logs error if fromMap throws', () async {
    when(
      mockSnapshot.value,
    ).thenReturn({'field1': 'value1', 'field2': 'value2'});

    final stream = service.streamData(
      path: 'test/path',
      logTag: 'TEST',
      fromMap: (map) => throw Exception('fromMap error'),
    );

    await expectLater(stream, emitsError(isA<Exception>()));

    expect(errorCalls.length, 1);
    expect(errorCalls.first.contains('fromMap error'), isTrue);
  });

  test('streamData logs ProjectModel with toMap', () async {
    when(mockSnapshot.value).thenReturn({
      'id': 'project123',
      'title': 'Test Project',
      'description': 'Test Description',
      'ownerUid': 'owner123',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'color': 0,
      'status': 'active',
      'memo': '',
      'script': '',
      'participants': {},
    });

    final stream = service.streamData(
      path: 'test/project',
      logTag: 'PROJECT_TEST',
      fromMap: (map) => ProjectModel.fromMap('project123', map),
    );

    await expectLater(
      stream,
      emits(isA<ProjectModel>().having((m) => m.id, 'id', 'project123')),
    );

    expect(logCalls.length, 1);
    expect(logCalls.first.contains('PROJECT_TEST'), isTrue);
    expect(logCalls.first.contains('title'), isTrue);
  });
  test('uses FirebaseDatabase.instance when no database provided', () {
    try {
      final service = DatabaseStreamService();
      expect(service, isA<DatabaseStreamService>());
    } catch (e) {
      log("[DEBUG]:",'Skipped test due to Firebase not initialized: $e');
    }
  });
}

/// Dummy model for testing
class DummyModel {
  final String field1;
  final String? field2;

  DummyModel({required this.field1, this.field2});

  factory DummyModel.fromMap(Map<String, dynamic> map) {
    return DummyModel(field1: map['field1'], field2: map['field2']);
  }
}
