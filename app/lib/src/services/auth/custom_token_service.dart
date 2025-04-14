import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CustomTokenService {
  final String url = dotenv.env['CUSTOM_TOKEN_API_URL']!;

  Future<String> createCustomToken(Map<String, dynamic> user) async {
    final filteredUser = user.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );

    try {
      final customTokenResponse = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(filteredUser),
      );

      if (customTokenResponse.statusCode != 200) {
        throw Exception(
          "Failed to create custom token. Status code: ${customTokenResponse.statusCode}",
        );
      }

      return customTokenResponse.body;
    } catch (error) {
      debugPrint("Error creating custom token: $error");
      rethrow;
    }
  }
}
