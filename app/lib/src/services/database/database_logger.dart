import 'dart:convert';
import 'package:flutter/material.dart';

/// Pretty log helper
/// json 형태로 데이터 출력
void log(String tag, dynamic data) {
  final pretty = const JsonEncoder.withIndent('  ').convert(data);
  debugPrint("[DatabaseService] $tag:\n$pretty");
}

/// Error log helper
void error(String tag, Object error) {
  debugPrint("[DatabaseService] $tag - error: $error");
}
