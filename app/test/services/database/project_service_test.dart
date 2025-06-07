import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/database_service.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

@GenerateMocks([
  DatabaseService,
  FirebaseDatabase,
  DatabaseReference,
  DataSnapshot,
])
import 'project_service_test.mocks.dart';

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockFirebaseDatabase mockFirebaseDatabase;
  late MockDatabaseReference mockRef;
  late MockDataSnapshot mockSnapshot;
  late ProjectService projectService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockFirebaseDatabase = MockFirebaseDatabase();
    mockRef = MockDatabaseReference();
    mockSnapshot = MockDataSnapshot();

    projectService = ProjectService(
      databaseService: mockDatabaseService,
      firebaseDatabase: mockFirebaseDatabase,
    );

    when(mockFirebaseDatabase.ref(any)).thenReturn(mockRef);
    when(mockRef.get()).thenAnswer((_) async => mockSnapshot);
  });

  group('ProjectService', () {
    test('writeProject calls writeDB and returns ProjectModel', () async {
      when(mockDatabaseService.writeDB(any, any)).thenAnswer((_) async {});

      final project = await projectService.writeProject(
        title: 'Test Title',
        description: 'Test Description',
        ownerUid: 'owner123',
        participants: {'owner123': 'owner'},
      );

      verify(mockDatabaseService.writeDB(any, any)).called(1);
      expect(project.title, 'Test Title');
      expect(project.description, 'Test Description');
      expect(project.ownerUid, 'owner123');
      expect(project.participants.containsKey('owner123'), true);
    });

    test('readProject returns ProjectModel when data exists', () async {
      final map = {
        'title': 'Test Title',
        'description': 'Test Description',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'ownerUid': 'owner123',
        'participants': {'owner123': 'owner'},
        'status': 'active',
        'estimatedTime': 0,
        'score': 0,
        'scheduledDate': null,
        'script': '',
        'memo': '',
        'scriptParts': [],
        'keywords': [],
      };

      when(
        mockDatabaseService.readDB<Map<String, dynamic>>(any),
      ).thenAnswer((_) async => map);

      final result = await projectService.readProject('projectId');

      expect(result, isNotNull);
      expect(result, isA<ProjectModel>());
      expect(result?.title, 'Test Title');
      expect(result?.ownerUid, 'owner123');
    });

    test('readProject returns null when no data', () async {
      when(
        mockDatabaseService.readDB<Map<String, dynamic>>(any),
      ).thenAnswer((_) async => null);

      final result = await projectService.readProject('nonexistent');

      expect(result, isNull);
    });

    test('updateProject calls updateDB with updatedAt', () async {
      when(mockDatabaseService.updateDB(any, any)).thenAnswer((_) async {});

      await projectService.updateProject('projectId', {
        'title': 'Updated Title',
      });

      verify(
        mockDatabaseService.updateDB(
          'projects/projectId',
          argThat(
            allOf(
              containsPair('title', 'Updated Title'),
              contains('updatedAt'),
            ),
          ),
        ),
      ).called(1);
    });

    test('deleteProject calls deleteDB', () async {
      when(mockDatabaseService.deleteDB(any)).thenAnswer((_) async {});

      await projectService.deleteProject('projectId');

      verify(mockDatabaseService.deleteDB('projects/projectId')).called(1);
    });

    test('fetchProjects filters projects by participant uid', () async {
      const testUid = 'user123';

      final mockChild1 = MockDataSnapshot();
      final mockChild2 = MockDataSnapshot();

      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.children).thenReturn([mockChild1, mockChild2]);

      // 첫 번째 프로젝트 참가자에 testUid 포함
      when(mockChild1.key).thenReturn('project1');
      when(mockChild1.value).thenReturn({
        'participants': {testUid: 'role1'},
        // ... 나머지 필드들 ...
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

      // 두 번째 프로젝트 참가자에 testUid 없음
      when(mockChild2.key).thenReturn('project2');
      when(mockChild2.value).thenReturn({
        'participants': {'otherUser': 'role2'},
        // ... 나머지 필드들 ...
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

      final projects = await projectService.fetchProjects(testUid);

      expect(projects.length, 1);
      expect(projects.first.id, 'project1');
      expect(projects.first.participants.containsKey(testUid), true);
    });

    test('initProject updates missing fields', () async {
      final project = ProjectModel(
        id: 'project1',
        title: 'Title',
        description: 'Desc',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ownerUid: 'owner1',
        participants: {'owner1': 'owner'},
        status: 'active',
        estimatedTime: 30,
        score: 80,
        scheduledDate: DateTime.now(),
        script: 'script',
        memo: 'memo',
        scriptParts: [],
        keywords: [],
      );

      final existingMap = {
        'title': 'Title',
        'description': 'Desc',
        'estimatedTime': null,
        'score': null,
      };

      when(
        mockDatabaseService.readDB<Map<String, dynamic>>(any),
      ).thenAnswer((_) async => existingMap);
      when(mockDatabaseService.updateDB(any, any)).thenAnswer((_) async {});

      await projectService.initProject(project);

      verify(mockDatabaseService.updateDB(any, any)).called(1);
    });
  });
}
