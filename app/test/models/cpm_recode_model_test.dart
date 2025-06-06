import 'package:flutter_test/flutter_test.dart';
import 'package:talk_pilot/src/models/cpm_record_model.dart';

void main() {
  group('CpmRecordModel', () {
    test('fromMap should correctly create an instance', () {
      final map = {
        'cpm': 123.45,
        'timestamp': '2025-06-06T12:34:56.000Z',
      };

      final model = CpmRecordModel.fromMap(map);

      expect(model.cpm, 123.45);
      expect(model.timestamp, DateTime.parse('2025-06-06T12:34:56.000Z'));
    });

    test('toMap should return correct map', () {
      final model = CpmRecordModel(
        cpm: 99.9,
        timestamp: DateTime.parse('2025-06-06T00:00:00.000Z'),
      );

      final map = model.toMap();

      expect(map['cpm'], 99.9);
      expect(map['timestamp'], '2025-06-06T00:00:00.000Z');
    });

    test('toJson should return same as toMap', () {
      final model = CpmRecordModel(
        cpm: 77.7,
        timestamp: DateTime.parse('2025-06-06T10:00:00.000Z'),
      );

      expect(model.toJson(), model.toMap());
    });

    test('fromMap should throw if fields are missing', () {
      final invalidMap = {
        'cpm': 100.0,
      };

      expect(() => CpmRecordModel.fromMap(invalidMap), throwsA(isA<TypeError>()));
    });

    test('fromMap should throw if timestamp is invalid format', () {
      final invalidMap = {
        'cpm': 100.0,
        'timestamp': 'not-a-date',
      };

      expect(() => CpmRecordModel.fromMap(invalidMap), throwsA(isA<FormatException>()));
    });
  });
}
