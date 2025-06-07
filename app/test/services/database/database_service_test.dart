import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';

@GenerateMocks([FirebaseDatabase, DatabaseReference, DataSnapshot, Query])
import 'database_service_test.mocks.dart';

void main() {
  late MockFirebaseDatabase mockFirebaseDatabase;
  late MockDatabaseReference mockDatabaseReference;
  late MockDataSnapshot mockDataSnapshot;
  late DatabaseService databaseService;

  setUp(() {
    mockFirebaseDatabase = MockFirebaseDatabase();
    mockDatabaseReference = MockDatabaseReference();
    mockDataSnapshot = MockDataSnapshot();

    databaseService = DatabaseService(database: mockFirebaseDatabase);

    when(mockFirebaseDatabase.ref(any)).thenReturn(mockDatabaseReference);
  });

  test('writeDB writes data to correct path', () async {
    when(mockDatabaseReference.set(any)).thenAnswer((_) async {});

    await databaseService.writeDB('test/path', {'key': 'value'});

    verify(mockDatabaseReference.set({'key': 'value'})).called(1);
  });

  test('readDB reads and returns data', () async {
    when(mockDatabaseReference.get()).thenAnswer((_) async => mockDataSnapshot);
    when(mockDataSnapshot.exists).thenReturn(true);
    when(mockDataSnapshot.value).thenReturn('testValue');

    final result = await databaseService.readDB<String>('test/path');

    expect(result, 'testValue');
  });

  test('readDB returns null when data does not exist', () async {
    when(mockDatabaseReference.get()).thenAnswer((_) async => mockDataSnapshot);
    when(mockDataSnapshot.exists).thenReturn(false);
    when(mockDataSnapshot.value).thenReturn(null);

    final result = await databaseService.readDB<String>('test/path');

    expect(result, isNull);
  });

  test('updateDB updates data at correct path', () async {
    when(mockDatabaseReference.update(any)).thenAnswer((_) async {});

    await databaseService.updateDB('test/path', {'key': 'updatedValue'});

    verify(mockDatabaseReference.update({'key': 'updatedValue'})).called(1);
  });

  test('deleteDB removes data at correct path', () async {
    when(mockDatabaseReference.remove()).thenAnswer((_) async {});

    await databaseService.deleteDB('test/path');

    verify(mockDatabaseReference.remove()).called(1);
  });

  test('fetchDB fetches and maps list of data', () async {
    when(mockFirebaseDatabase.ref(any)).thenReturn(mockDatabaseReference);
    when(mockDatabaseReference.get()).thenAnswer((_) async => mockDataSnapshot);

    // Simulate children snapshots
    final mockChildSnapshot = MockDataSnapshot();
    when(mockDataSnapshot.exists).thenReturn(true);
    when(mockDataSnapshot.children).thenReturn([mockChildSnapshot]);
    when(mockChildSnapshot.value).thenReturn({'key': 'value'});

    final result = await databaseService.fetchDB<Map<String, dynamic>>(
      path: 'test/path',
      fromMap: (map) => map,
    );

    expect(result.length, 1);
    expect(result.first, {'key': 'value'});
  });
  test('writeDB throws and logs error on exception', () async {
    final ref = MockDatabaseReference();
    when(mockFirebaseDatabase.ref(any)).thenReturn(ref);
    when(ref.set(any)).thenThrow(Exception('write error'));

    expectLater(
      () => databaseService.writeDB('test/path', {'key': 'value'}),
      throwsA(isA<Exception>()),
    );
  });

  test('readDB throws and logs error on exception', () async {
    final ref = MockDatabaseReference();
    when(mockFirebaseDatabase.ref(any)).thenReturn(ref);
    when(ref.get()).thenThrow(Exception('read error'));

    expectLater(
      () => databaseService.readDB<Map<String, dynamic>>('test/path'),
      throwsA(isA<Exception>()),
    );
  });

  test('deleteDB throws and logs error on exception', () async {
    final ref = MockDatabaseReference();
    when(mockFirebaseDatabase.ref(any)).thenReturn(ref);
    when(ref.remove()).thenThrow(Exception('delete error'));

    expectLater(
      () => databaseService.deleteDB('test/path'),
      throwsA(isA<Exception>()),
    );
  });

  test('fetchDB throws and logs error on exception', () async {
    when(mockFirebaseDatabase.ref(any)).thenThrow(Exception('fetch error'));

    expectLater(
      () => databaseService.fetchDB<Map<String, dynamic>>(
        path: 'test/path',
        fromMap: (map) => map,
      ),
      throwsA(isA<Exception>()),
    );
  });
  test('uses provided FirebaseDatabase instance if given', () {
    final service = DatabaseService(database: mockFirebaseDatabase);

    expect(service.database, mockFirebaseDatabase);
  });
  test('readDB returns Map<String, dynamic> correctly', () async {
    final mockSnapshot = MockDataSnapshot();
    when(mockDatabaseReference.get()).thenAnswer((_) async => mockSnapshot);
    when(mockSnapshot.exists).thenReturn(true);
    when(mockSnapshot.value).thenReturn({'key': 'value'});

    final result = await databaseService.readDB<Map<String, dynamic>>(
      'test/path',
    );

    expect(result, {'key': 'value'});
  });
  test('updateDB logs error when exception thrown', () async {
    when(
      mockDatabaseReference.update(any),
    ).thenThrow(Exception('update error'));

    expect(
      () => databaseService.updateDB('test/path', {'key': 'value'}),
      throwsException,
    );
  });
  test('fetchDB returns empty list when no data', () async {
    final mockSnapshot = MockDataSnapshot();
    when(mockDatabaseReference.get()).thenAnswer((_) async => mockSnapshot);
    when(mockSnapshot.exists).thenReturn(false);

    final result = await databaseService.fetchDB<Map<String, dynamic>>(
      path: 'test/path',
      fromMap: (map) => map,
    );

    expect(result, isEmpty);
  });
}
