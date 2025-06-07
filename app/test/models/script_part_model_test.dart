import 'package:flutter_test/flutter_test.dart';
import 'package:talk_pilot/src/models/script_part_model.dart';

void main() {
  group('ScriptPartModel', () {
    test('fromMap should correctly create an instance', () {
      final map = {
        'uid': 'user123',
        'startIndex': 0,
        'endIndex': 10,
      };

      final model = ScriptPartModel.fromMap(map);

      expect(model.uid, 'user123');
      expect(model.startIndex, 0);
      expect(model.endIndex, 10);
    });

    test('toMap should return correct map', () {
      final model = ScriptPartModel(
        uid: 'user456',
        startIndex: 5,
        endIndex: 15,
      );

      final map = model.toMap();

      expect(map['uid'], 'user456');
      expect(map['startIndex'], 5);
      expect(map['endIndex'], 15);
    });

    test('fromMap and toMap round trip should be equal', () {
      final original = ScriptPartModel(
        uid: 'roundtrip',
        startIndex: 1,
        endIndex: 2,
      );

      final map = original.toMap();
      final recreated = ScriptPartModel.fromMap(map);

      expect(recreated.uid, original.uid);
      expect(recreated.startIndex, original.startIndex);
      expect(recreated.endIndex, original.endIndex);
    });
  });
}
