import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventColorStorage {
  static Future<Map<String, int>> loadEventColors() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, int>{};

    for (var key in prefs.getKeys()) {
      if (key.startsWith('color_')) {
        final title = key.substring(6);
        final value = prefs.getInt(key);
        if (value != null) map[title] = value;
      }
    }

    return map;
  }

  static Future<void> saveEventColor(String title, Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('color_$title', color.value);
  }
}
