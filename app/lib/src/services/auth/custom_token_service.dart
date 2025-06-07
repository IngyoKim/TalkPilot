import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class CustomTokenService {
  final http.Client _client;
  final String url;

  CustomTokenService({
    http.Client? client,
    String? url,
  })  : _client = client ?? http.Client(),
        url = url ?? dotenv.env['CUSTOM_TOKEN_API_URL']!;

  Future<String> createCustomToken(Map<String, dynamic> user) async {
    final filteredUser = user.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );

    try {
      final customTokenResponse = await _client.post(
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
