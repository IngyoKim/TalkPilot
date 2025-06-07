import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/models/script_part_model.dart';
import 'package:talk_pilot/src/models/user_model.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/services/database/project_stream_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/utils/project/estimated_time_service.dart';

// @GenerateMocks 선언
@GenerateMocks([ProjectStreamService, ProjectService, UserService])
import 'estimated_time_service_test.mocks.dart';

void main() {
  late MockProjectStreamService mockProjectStreamService;
  late MockProjectService mockProjectService;
  late MockUserService mockUserService;
  late EstimatedTimeService estimatedTimeService;

  setUp(() {
    mockProjectStreamService = MockProjectStreamService();
    mockProjectService = MockProjectService();
    mockUserService = MockUserService();

    estimatedTimeService = EstimatedTimeService(
      projectStreamService: mockProjectStreamService,
      projectService: mockProjectService,
      userService: mockUserService,
    );
  });

  test('estimatedTime 계산 테스트 - scriptParts가 없는 경우', () async {
    const projectId = 'test_project_1';

    final controller = StreamController<ProjectModel>();

    when(
      mockProjectStreamService.streamProject(projectId),
    ).thenAnswer((_) => controller.stream);

    // owner user cpm 설정
    final user = UserModel(
      uid: 'owner_uid',
      name: '',
      email: '',
      nickname: '',
      cpm: 300.0,
    );

    when(mockUserService.readUser('owner_uid')).thenAnswer((_) async => user);

    estimatedTimeService.streamEstimatedTime(projectId, force: true);

    final project = ProjectModel(
      id: projectId,
      title: '',
      description: '',
      ownerUid: 'owner_uid',
      participants: {},
      status: 'preparing',
      script: 'This is a test script with some keywords.',
      scriptParts: [],
      keywords: ['test', 'keywords'],
    );

    controller.add(project);

    await Future.delayed(Duration(milliseconds: 100));

    final expectedScriptLength = project.script!.length;
    final expectedBaseTime = (expectedScriptLength / user.cpm!) * 60;
    final expectedKeywordCount = 2; // 'test', 'keywords' 각각 1개씩 등장
    final expectedKeywordTime = expectedKeywordCount * 0.5;

    final expectedTotalTimeSecDouble = double.parse(
      ((expectedBaseTime + expectedKeywordTime)).toStringAsFixed(2),
    );

    verify(
      mockProjectService.updateProject(projectId, {
        'estimatedTime': expectedTotalTimeSecDouble,
      }),
    ).called(1);

    await controller.close();
  });

  test('estimatedTime 계산 테스트 - scriptParts가 있는 경우', () async {
    const projectId = 'test_project_2';

    final controller = StreamController<ProjectModel>();

    when(
      mockProjectStreamService.streamProject(projectId),
    ).thenAnswer((_) => controller.stream);

    // 각 part user cpm 설정
    final user1 = UserModel(
      uid: 'user1',
      name: '',
      email: '',
      nickname: '',
      cpm: 200.0,
    );

    final user2 = UserModel(
      uid: 'user2',
      name: '',
      email: '',
      nickname: '',
      cpm: 400.0,
    );

    when(mockUserService.readUser('user1')).thenAnswer((_) async => user1);
    when(mockUserService.readUser('user2')).thenAnswer((_) async => user2);

    estimatedTimeService.streamEstimatedTime(projectId, force: true);

    final script = 'Part one. Part two.';
    final part1 = ScriptPartModel(
      uid: 'user1',
      startIndex: 0,
      endIndex: 9, // 'Part one'
    );
    final part2 = ScriptPartModel(
      uid: 'user2',
      startIndex: 10,
      endIndex: script.length,
    );

    final project = ProjectModel(
      id: projectId,
      title: '',
      description: '',
      ownerUid: 'owner_uid',
      participants: {},
      status: 'preparing',
      script: script,
      scriptParts: [part1, part2],
      keywords: [],
    );

    controller.add(project);

    await Future.delayed(Duration(milliseconds: 100));

    final text1Length =
        script.substring(part1.startIndex, part1.endIndex).trim().length;
    final text2Length =
        script.substring(part2.startIndex, part2.endIndex).trim().length;

    final expectedTime1 = (text1Length / user1.cpm!) * 60;
    final expectedTime2 = (text2Length / user2.cpm!) * 60;

    final expectedTotalTimeSecDouble = double.parse(
      (expectedTime1 + expectedTime2).toStringAsFixed(2),
    );

    verify(
      mockProjectService.updateProject(projectId, {
        'estimatedTime': expectedTotalTimeSecDouble,
      }),
    ).called(1);

    await controller.close();
  });
}
