import 'package:flutter_test/flutter_test.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:talk_pilot/src/utils/project/script_progress_service.dart';

@GenerateMocks([ProjectService])
import 'script_progress_service_test.mocks.dart';

void main() {
  late ScriptProgressService scriptProgressService;
  late MockProjectService mockProjectService;

  setUp(() {
    mockProjectService = MockProjectService();
    scriptProgressService = ScriptProgressService(
      projectService: mockProjectService,
    );
  });

  test('splitText correctly splits text', () {
    final text = 'Hello, world! This is a test.';
    final result = scriptProgressService.splitText(text);

    expect(result, ['Hello', 'world', 'This', 'is', 'a', 'test']);
  });

  test('calculateProgressByLastMatch works correctly', () async {
    final projectId = 'test_project';
    final script = 'Hello world this is a test script';
    final project = ProjectModel(
      id: projectId,
      title: '',
      description: '',
      ownerUid: '',
      participants: {},
      status: '',
      script: script,
    );

    when(
      mockProjectService.readProject(projectId),
    ).thenAnswer((_) async => project);

    await scriptProgressService.loadScript(projectId);

    final recognizedText = 'Hello world this is a test';
    final progress = scriptProgressService.calculateProgressByLastMatch(
      recognizedText,
    );

    expect(progress, closeTo(6 / 7, 0.01));
  });

  test('calculateAccuracy works correctly', () async {
    final projectId = 'test_project';
    final script = 'Hello world this is a test script';
    final project = ProjectModel(
      id: projectId,
      title: '',
      description: '',
      ownerUid: '',
      participants: {},
      status: '',
      script: script,
    );

    when(
      mockProjectService.readProject(projectId),
    ).thenAnswer((_) async => project);

    await scriptProgressService.loadScript(projectId);

    final recognizedText = 'Hello this is a';
    final accuracy = scriptProgressService.calculateAccuracy(recognizedText);

    expect(accuracy, greaterThan(0));
    expect(accuracy, lessThanOrEqualTo(1));
  });
}
