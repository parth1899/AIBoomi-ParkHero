import 'dart:convert';

import 'api_client.dart';

class AuthService {
  static String? _token;

  static String? get token => _token;

  static Future<bool> login({
    required String username,
    required String password,
  }) async {
    final body = {
      'username': username,
      'password': password,
    };

    var response = await ApiClient.post(
      '/api/auth/token/',
      body: body,
    );

    if (response.statusCode != 200) {
      response = await ApiClient.post(
        '/api/auth/login/',
        body: body,
      );
    }

    if (response.statusCode != 200) {
      return false;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      return false;
    }

    _token = token;
    return true;
  }

  static void clear() {
    _token = null;
  }
}
