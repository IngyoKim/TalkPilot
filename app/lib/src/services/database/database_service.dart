import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:talk_pilot/src/services/database/database_logger.dart';

class DatabaseService {
  final FirebaseDatabase _database;
  FirebaseDatabase get database => _database;

  DatabaseService({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  /// Create or overwrite data at [path]
  Future<void> writeDB(String path, Map<String, dynamic> data) async {
    final ref = _database.ref(path);
    try {
      await ref.set(data);
      log("[WRITE] $path", data);
    } catch (e) {
      error("[WRITE] $path", e);
      rethrow;
    }
  }

  /// Read data from [path] and cast to type [T]
  Future<T?> readDB<T>(String path) async {
    final ref = _database.ref(path);
    try {
      final snapshot = await ref.get();
      if (!snapshot.exists || snapshot.value == null) {
        debugPrint("[READ] $path - no data");
        return null;
      }

      final raw = snapshot.value!;

      // T가 Map<String, dynamic>인 경우 강제 변환
      if (T == Map<String, dynamic>) {
        return Map<String, dynamic>.from(raw as Map) as T;
      }

      return raw as T;
    } catch (e) {
      error("[READ] $path", e);
      rethrow;
    }
  }

  /// Update data at [path]
  Future<void> updateDB(String path, Map<String, dynamic> updates) async {
    final ref = _database.ref(path);
    try {
      await ref.update(updates);
      log("[UPDATE] $path", updates);
    } catch (e) {
      error("[UPDATE] $path", e);
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
      error("[DELETE] $path", e);
      rethrow;
    }
  }

  /// Fetch multiple child nodes from [path] and map to list of [T] using [fromMap]
  Future<List<T>> fetchDB<T>({
    required String path,
    required T Function(Map<String, dynamic>) fromMap,
    Query? query,
  }) async {
    try {
      final snapshot = await (query ?? _database.ref(path)).get();

      if (snapshot.exists) {
        final data =
            snapshot.children
                .map(
                  (child) =>
                      fromMap(Map<String, dynamic>.from(child.value as Map)),
                )
                .toList();
        log("[FETCH] $path", data);
        return data;
      } else {
        debugPrint("[FETCH] $path - no data");
        return [];
      }
    } catch (e) {
      error("[FETCH] $path", e);
      rethrow;
    }
  }
}
