import 'dart:convert';

import '../types/models.dart';
import 'api_client.dart';

class BookingService {
  static Future<List<Booking>> fetchMyBookings() async {
    final response = await ApiClient.get(
      '/api/mobile/bookings/me/',
      auth: true,
    );
    if (response.statusCode != 200) {
      return const [];
    }

    final decoded = json.decode(response.body);
    final list = _extractList(decoded);
    return list
      .map((item) => _mapBooking(item as Map<String, dynamic>))
      .toList();
  }

  static Future<Booking?> createBooking({
    required int facilityId,
    required double durationHours,
  }) async {
    final response = await ApiClient.post(
      '/api/mobile/bookings/',
      auth: true,
      body: {
        'facility_id': facilityId,
        'duration_hours': durationHours,
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      return null;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return _mapBooking(data);
  }

  static Booking _mapBooking(Map<String, dynamic> data) {
    final startTime = _tryParseDate(data['start_time'] as String?);
    final endTime = _tryParseDate(data['end_time'] as String?);
    final dateLabel = _formatDateRange(startTime, endTime);

    return Booking(
      id: data['id'].toString(),
      lotName: data['facility_name'] as String? ?? 'Parking Facility',
      spotLabel: data['spot_code'] as String? ?? 'Spot',
        floor: data['floor'] as String? ??
          data['floor_label'] as String? ??
          'Level',
      dateLabel: dateLabel,
      timeLabel: _formatDuration(startTime, endTime),
      status: _mapBookingStatus(data['status']?.toString()),
      imageAsset: 'assets/images/garage_header.svg',
      accessCode: data['access_code'] as String?,
      qrPayload: data['qr_payload'] as String?,
      requiresApproval: data['requires_approval'] as bool?,
      hostName: data['host_name'] as String?,
      rejectionReason: data['rejection_reason'] as String?,
    );
  }

  static BookingStatus _mapBookingStatus(String? status) {
    switch (status) {
      case 'pending_approval':
        return BookingStatus.pending;
      case 'reserved':
        return BookingStatus.reserved;
      case 'active':
        return BookingStatus.active;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'rejected':
        return BookingStatus.rejected;
      default:
        return BookingStatus.active;
    }
  }

  static DateTime? _tryParseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }

  static String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null) return 'Today';
    final startLabel = _formatDateTime(start);
    if (end == null) return startLabel;
    final endLabel = _formatTime(end);
    return '$startLabel - $endLabel';
  }

  static String _formatDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '';
    final minutes = end.difference(start).inMinutes;
    if (minutes <= 0) return '';
    if (minutes < 60) return '${minutes}m';
    final hours = minutes / 60;
    if (hours == hours.roundToDouble()) {
      return '${hours.toInt()}h';
    }
    return '${hours.toStringAsFixed(1)}h';
  }

  static String _formatDateTime(DateTime dateTime) {
    final month = _monthNames[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final time = _formatTime(dateTime);
    return '$month $day, $time';
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  static List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final results = decoded['results'];
      if (results is List) return results;
      final data = decoded['data'];
      if (data is List) return data;
    }
    return const [];
  }
}

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
