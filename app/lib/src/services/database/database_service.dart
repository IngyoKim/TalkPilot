import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Create or overwrite data at [path]
  Future<void> writeDB(String path, Map<String, dynamic> data) async {
    final ref = _database.ref(path);
    try {
      await ref.set(data);
      _log("[WRITE] $path", data);
    } catch (e) {
      _error("[WRITE] $path", e);
      rethrow;
    }
  }

  /// Read data from [path] and cast to type [T]
  Future<T?> readDB<T>(String path) async {
    final ref = _database.ref(path);
    try {
      final snapshot = await ref.get();
      if (snapshot.exists && snapshot.value != null) {
        _log("[READ] $path", snapshot.value);
        return snapshot.value as T;
      } else {
        debugPrint("[READ] $path - no data");
        return null;
      }
    } catch (e) {
      _error("[READ] $path", e);
      rethrow;
    }
  }

  /// Delete data at [path]
  Future<void> deleteDB(String path) async {
    final ref = _database.ref(path);
    try {
      await ref.remove();
      debugPrint("[DELETE] $path - success");
    } catch (e) {
      _error("[DELETE] $path", e);
      rethrow;
    }
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
