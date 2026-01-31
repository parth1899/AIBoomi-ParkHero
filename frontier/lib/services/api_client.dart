import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';

class ApiClient {
  static final http.Client _client = http.Client();

  static Future<http.Response> get(
    String path, {
    bool auth = false,
  }) async {
    final uri = Uri.parse('$apiBaseUrl$path');
    final headers = await _buildHeaders(auth: auth);
    return _client.get(uri, headers: headers);
  }

  static Future<http.Response> post(
    String path, {
    bool auth = false,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$apiBaseUrl$path');
    final headers = await _buildHeaders(auth: auth);
    return _client.post(
      uri,
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    );
  }

  static Future<Map<String, String>> _buildHeaders({required bool auth}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (auth) {
      final token = AuthService.token;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Token $token';
      }
    }
    return headers;
  }
}
