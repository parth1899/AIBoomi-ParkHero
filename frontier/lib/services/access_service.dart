import 'dart:convert';

import '../types/models.dart';
import 'api_client.dart';

class AccessService {
  static Future<AccessValidationResult?> validateAccessCode(
    String accessCode,
  ) async {
    final response = await ApiClient.post(
      '/api/mobile/access/validate/',
      body: {
        'access_code': accessCode,
      },
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return AccessValidationResult(
      valid: data['valid'] as bool? ?? false,
      bookingId: data['booking_id']?.toString(),
      facility: data['facility'] as String?,
      spot: data['spot'] as String?,
      status: data['status'] as String?,
    );
  }
}
