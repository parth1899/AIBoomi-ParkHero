import 'dart:convert';

import '../types/models.dart';
import 'api_client.dart';

class LockboxService {
  static Future<LockboxQrResult?> fetchQrForBooking(String bookingId) async {
    final response = await ApiClient.get(
      '/api/lockbox/qr/$bookingId/',
      auth: true,
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return LockboxQrResult(
      bookingId: data['booking_id']?.toString() ?? bookingId,
      qrPayload: data['qr_payload'] as String?,
      qrImageBase64: data['qr_image_base64'] as String?,
      accessCode: data['access_code'] as String?,
      facility: data['facility'] as String?,
      spot: data['spot'] as String?,
    );
  }

  static Future<AccessValidationResult?> validateAccessCode(
    String accessCode,
  ) async {
    final response = await ApiClient.post(
      '/api/lockbox/validate/',
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

  static Future<BarrierValidationResult?> validateBarrierAccess({
    required String qrCode,
    required String deviceCode,
  }) async {
    final response = await ApiClient.post(
      '/api/lockbox/barrier/validate/',
      body: {
        'qr_code': qrCode,
        'device_code': deviceCode,
      },
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return BarrierValidationResult(
      valid: data['valid'] as bool? ?? false,
      action: data['action'] as String?,
      facility: data['facility'] as String?,
      spot: data['spot'] as String?,
      bookingId: data['booking_id']?.toString(),
      spotsAvailable: (data['spots_available'] as num?)?.toInt(),
      error: data['error'] as String?,
    );
  }
}
