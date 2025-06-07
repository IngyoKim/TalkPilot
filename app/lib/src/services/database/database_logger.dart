import 'dart:convert';
import 'package:flutter/material.dart';

typedef LogFunction = void Function(String tag, dynamic data);
typedef ErrorFunction = void Function(String tag, Object error);

LogFunction dbLog = (tag, data) {
  final pretty = const JsonEncoder.withIndent('  ').convert(data);
  debugPrint("[DatabaseService] $tag:\n$pretty");
};

ErrorFunction dbError = (tag, error) {
  debugPrint("[DatabaseService] $tag - error: $error");
};

void log(String tag, dynamic data) => dbLog(tag, data);
void error(String tag, Object error) => dbError(tag, error);

