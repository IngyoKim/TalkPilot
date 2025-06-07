import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/database_stream_service.dart';
import 'package:talk_pilot/src/services/database/project_stream_service.dart';

import 'project_stream_service_test.mocks.dart';

@GenerateMocks([
  DatabaseStreamService,
  FirebaseDatabase,
  DatabaseReference,
  DatabaseEvent,
  DataSnapshot,
])
void main() {
  late MockDatabaseStreamService mockStreamHelper;
  late MockFirebaseDatabase mockFirebaseDatabase;
  late MockDatabaseReference mockRef;
  late MockDatabaseEvent mockEvent;
  late MockDataSnapshot mockSnapshot;
  late ProjectStreamService projectStreamService;

  const testProjectId = 'project123';
  const testUserId = 'user123';

  setUp(() {
    mockStreamHelper = MockDatabaseStreamService();
    mockFirebaseDatabase = MockFirebaseDatabase();
    mockRef = MockDatabaseReference();
    mockEvent = MockDatabaseEvent();
    mockSnapshot = MockDataSnapshot();

    // ProjectStreamService 인스턴스를 직접 생성하고 Mock 주입
    projectStreamService = ProjectStreamService(
      streamHelper: mockStreamHelper,
      firebaseDatabase: mockFirebaseDatabase,
    );

    when(mockFirebaseDatabase.ref(any)).thenReturn(mockRef);
    when(mockRef.onValue).thenAnswer((_) => Stream.value(mockEvent));
    when(mockEvent.snapshot).thenReturn(mockSnapshot);
  });

  test('streamProject streams ProjectModel from streamHelper', () async {
    final testProject = ProjectModel(
      id: testProjectId,
      title: 'Test Project',
      description: 'Test Description',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ownerUid: 'owner1',
      participants: {testUserId: 'role1'},
      status: 'active',
      estimatedTime: 10,
      score: 5,
      scheduledDate: null,
      script: '',
      memo: '',
      scriptParts: [],
      keywords: [],
    );

    when(mockStreamHelper.streamData<ProjectModel>(
      path: anyNamed('path'),
      fromMap: anyNamed('fromMap'),
      logTag: anyNamed('logTag'),
    )).thenAnswer((_) => Stream.value(testProject));

    final stream = projectStreamService.streamProject(testProjectId);

    await expectLater(
      stream,
      emits(predicate<ProjectModel>(
          (proj) => proj.id == testProjectId && proj.title == 'Test Project')),
    );

    verify(mockStreamHelper.streamData<ProjectModel>(
      path: 'projects/$testProjectId',
      fromMap: anyNamed('fromMap'),
      logTag: 'Project:$testProjectId',
    )).called(1);
  });

  test('streamUserProjects streams filtered projects by uid', () async {
    final mockChild1 = MockDataSnapshot();
    final mockChild2 = MockDataSnapshot();

    when(mockSnapshot.exists).thenReturn(true);
    when(mockSnapshot.children).thenReturn([mockChild1, mockChild2]);

    when(mockChild1.key).thenReturn('project1');
    when(mockChild1.value).thenReturn({
      'participants': {testUserId: 'role1'},
      'title': 'Project 1',
      'ownerUid': 'owner1',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'description': '',
      'status': 'active',
      'estimatedTime': 10,
      'score': 5,
      'scheduledDate': null,
      'script': '',
      'memo': '',
      'scriptParts': [],
      'keywords': [],
    });

    when(mockChild2.key).thenReturn('project2');
    when(mockChild2.value).thenReturn({
      'participants': {'otherUser': 'role2'},
      'title': 'Project 2',
      'ownerUid': 'owner2',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'description': '',
      'status': 'active',
      'estimatedTime': 20,
      'score': 7,
      'scheduledDate': null,
      'script': '',
      'memo': '',
      'scriptParts': [],
      'keywords': [],
    });

    final stream = projectStreamService.streamUserProjects(testUserId);

    await expectLater(
      stream,
      emits(predicate<List<ProjectModel>>((projects) =>
          projects.length == 1 &&
          projects.first.id == 'project1' &&
          projects.first.participants.containsKey(testUserId))),
    );

    verify(mockFirebaseDatabase.ref('projects')).called(1);
  });

  test('streamUserProjects returns empty list if no data', () async {
    when(mockSnapshot.exists).thenReturn(false);

    final stream = projectStreamService.streamUserProjects(testUserId);

    await expectLater(stream, emits([]));
  });
}
