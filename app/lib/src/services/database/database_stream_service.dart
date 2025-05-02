import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class DatabaseStreamService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// 단일 객체를 실시간 구독
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
        _log("[STREAM:$logTag] $path", model);
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
