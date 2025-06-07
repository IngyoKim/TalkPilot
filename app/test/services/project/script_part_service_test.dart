import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/models/script_part_model.dart';
import 'package:talk_pilot/src/utils/project/script_part_service.dart';

void main() {
  late ScriptPartService service;
  late ProjectModel project;

  setUp(() {
    service = ScriptPartService();

    project = ProjectModel(
      id: 'p1',
      title: 'test project',
      description: 'test desc',
      ownerUid: 'user1',
      participants: {'user1': 'member', 'user2': 'member'},
      status: 'preparing',
      script: 'Hello world',
    );
  });

  test('getColorForUid returns consistent color for uid', () {
    final color1 = service.getColorForUid('user1', project);
    final color2 = service.getColorForUid('user2', project);

    expect(color1, isNot(equals(color2)));

    // 같은 uid는 같은 색상
    expect(service.getColorForUid('user1', project), equals(color1));
  });

  test('overwriteParts correctly overwrites parts', () {
    final initialParts = [
      ScriptPartModel(uid: 'user1', startIndex: 0, endIndex: 5),
      ScriptPartModel(uid: 'user2', startIndex: 5, endIndex: 11),
    ];

    final result = service.overwriteParts(
      currentParts: initialParts,
      selectedUid: 'user1',
      start: 3,
      end: 8,
    );

    // 결과적으로 파트들이 잘 나눠지는지 확인
    expect(result.length, 3);

    expect(result[0].uid, 'user1');
    expect(result[0].startIndex, 0);
    expect(result[0].endIndex, 3);

    expect(result[1].uid, 'user1'); // 새로 추가된 파트
    expect(result[1].startIndex, 3);
    expect(result[1].endIndex, 8);

    expect(result[2].uid, 'user2');
    expect(result[2].startIndex, 8);
    expect(result[2].endIndex, 11);
  });

  test('buildTextSpans builds correct spans', () {
    final script = 'Hello world';
    final parts = [
      ScriptPartModel(uid: 'user1', startIndex: 0, endIndex: 5),
      ScriptPartModel(uid: 'user2', startIndex: 6, endIndex: 11),
    ];

    final spans = service.buildTextSpans(
      project: project,
      scriptParts: parts,
      dragStart: null,
      dragEnd: null,
      script: script,
    );

    // 예상: "Hello ", "w", "orld" → spans 수는 최소 2개 이상
    expect(spans.length, greaterThanOrEqualTo(2));

    final spanTexts =
        spans.map((span) {
          if (span is TextSpan) {
            return span.text ?? '';
          } else {
            return '';
          }
        }).join();

    expect(spanTexts, equals(script));
  });
  test('buildTextSpans builds correct spans with drag range', () {
    final script = 'Hello world';
    final parts = [
      ScriptPartModel(uid: 'user1', startIndex: 0, endIndex: 5),
      ScriptPartModel(uid: 'user2', startIndex: 6, endIndex: 11),
    ];

    final spans = service.buildTextSpans(
      project: project,
      scriptParts: parts,
      dragStart: 3,
      dragEnd: 8,
      script: script,
    );

    final hasDragSpan = spans.any((span) {
      return span is TextSpan &&
          span.style?.backgroundColor == Colors.yellowAccent;
    });

    expect(hasDragSpan, isTrue);

    final spanTexts =
        spans.map((span) {
          if (span is TextSpan) {
            return span.text ?? '';
          } else {
            return '';
          }
        }).join();

    expect(spanTexts, equals(script));
  });
}
