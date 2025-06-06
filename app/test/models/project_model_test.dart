import 'package:flutter_test/flutter_test.dart';
import 'package:talk_pilot/src/models/project_model.dart';

void main() {
  group('ProjectModel', () {
    final now = DateTime.parse('2025-06-06T12:00:00.000Z');

    final baseMap = {
      'title': 'Test Project',
      'description': 'Testing...',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'ownerUid': 'user123',
      'participants': {'user123': 'owner', 'user456': 'member'},
      'status': 'preparing',
      'estimatedTime': 300,
      'score': 92.5,
      'script': 'Hello world',
      'scheduledDate': now.toIso8601String(),
      'memo': 'Important note',
      'scriptParts': [
        {'uid': 'user123', 'startIndex': 0, 'endIndex': 10},
      ],
      'keywords': ['flutter', 'test'],
    };

    test('fromMap creates valid ProjectModel', () {
      final model = ProjectModel.fromMap('abc123', baseMap);

      expect(model.id, 'abc123');
      expect(model.title, 'Test Project');
      expect(model.description, 'Testing...');
      expect(model.createdAt, now);
      expect(model.updatedAt, now);
      expect(model.ownerUid, 'user123');
      expect(model.participants['user456'], 'member');
      expect(model.status, 'preparing');
      expect(model.estimatedTime, 300);
      expect(model.score, 92.5);
      expect(model.script, 'Hello world');
      expect(model.scheduledDate, now);
      expect(model.memo, 'Important note');
      expect(model.keywords, contains('flutter'));
      expect(model.scriptParts?.first.uid, 'user123');
      expect(model.scriptParts?.first.startIndex, 0);
      expect(model.scriptParts?.first.endIndex, 10);
    });

    test('toMap returns expected map', () {
      final model = ProjectModel.fromMap('abc123', baseMap);
      final result = model.toMap();

      expect(result['title'], 'Test Project');
      expect(result['participants'], {'user123': 'owner', 'user456': 'member'});
      expect(result['estimatedTime'], 300);
      expect(result['score'], 92.5);
      expect(result['scriptParts']?.first['uid'], 'user123');
    });

    test('copyWith correctly overrides fields', () {
      final model = ProjectModel.fromMap('abc123', baseMap);
      final updated = model.copyWith(title: 'Updated Title', score: 99.0);

      expect(updated.title, 'Updated Title');
      expect(updated.score, 99.0);
      expect(updated.description, model.description);
    });

    test('ProjectFieldExt.key returns correct string', () {
      expect(ProjectField.title.key, 'title');
      expect(ProjectField.scriptParts.key, 'scriptParts');
    });

    test('ProjectRoleExtension.canEdit returns correct values', () {
      expect(ProjectRole.owner.canEdit, true);
      expect(ProjectRole.editor.canEdit, true);
      expect(ProjectRole.member.canEdit, false);
    });

    test('fromMap handles null score', () {
      final tempMap = Map<String, dynamic>.from(baseMap)..remove('score');
      final model = ProjectModel.fromMap('id', tempMap);

      expect(model.score, 0.0);
    });

    test('copyWith replaces scriptParts', () {
      final model = ProjectModel.fromMap('abc123', baseMap);
      final updated = model.copyWith(scriptParts: []);

      expect(updated.scriptParts, isEmpty);
    });
    test('copyWith replaces keywords', () {
      final model = ProjectModel.fromMap('abc123', baseMap);
      final updated = model.copyWith(keywords: ['a', 'b']);

      expect(updated.keywords, contains('a'));
    });
    test('fromMap handles null participants', () {
      final minimalMap = {
        'title': 'No Participants Test',
        'description': 'Testing no participants',
        'ownerUid': 'user999',
        'status': 'preparing',
      };

      final model = ProjectModel.fromMap('null-case', minimalMap);

      expect(model.participants, isEmpty);
    });
  });
}
