import 'package:firebase_database/firebase_database.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/database/database_logger.dart';

class DatabaseStreamService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Stream<T> streamData<T>({
    required String path,
    required T Function(Map<String, dynamic>) fromMap,
    required String logTag,
  }) {
    final ref = _database.ref(path);
    return ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) {
        error("[STREAM:$logTag] $path", 'No data');
        throw Exception('[$logTag] No data found at: $path');
      }

      try {
        final map = Map<String, dynamic>.from(data as Map);
        final model = fromMap(map);

        if (model is ProjectModel) {
          log("[STREAM:$logTag] $path", model.toMap());
        } else {
          log("[STREAM:$logTag] $path", model.toString());
        }

        return model;
      } catch (e) {
        error("[STREAM:$logTag] $path", e);
        rethrow;
      }
    });
  }
}
