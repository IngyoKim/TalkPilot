import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:talk_pilot/src/models/project_model.dart';

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
        _error("[STREAM:$logTag] $path", 'No data');
        throw Exception('[$logTag] No data found at: $path');
      }

      try {
        final map = Map<String, dynamic>.from(data as Map);
        final model = fromMap(map);

        if (model is ProjectModel) {
          _log("[STREAM:$logTag] $path", model.toMap());
        } else {
          _log("[STREAM:$logTag] $path", model.toString());
        }

        return model;
      } catch (e) {
        _error("[STREAM:$logTag] $path", e);
        rethrow;
      }
    });
  }

  /// Pretty log helper
  /// json 형태로 데이터 출력
  void _log(String tag, dynamic data) {
    final pretty = const JsonEncoder.withIndent('  ').convert(data);
    debugPrint("[DatabaseService] $tag:\n$pretty");
  }

  /// Error log helper
  void _error(String tag, Object error) {
    debugPrint("[DatabaseService] $tag - error: $error");
  }
}
