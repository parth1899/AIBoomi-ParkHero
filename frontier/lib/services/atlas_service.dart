import 'dart:convert';

import '../types/models.dart';
import 'api_client.dart';

class AtlasService {
  static Future<List<ParkingLot>> fetchMyListings() async {
    final response = await ApiClient.get(
      '/api/atlas/facilities/my-listings/',
      auth: true,
    );

    if (response.statusCode != 200) {
      return const [];
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data
        .map((item) => FacilityMapper.mapFacility(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<IncomingBooking>> fetchIncomingBookings({
    String? facilityId,
  }) async {
    final query = facilityId == null || facilityId.isEmpty
        ? ''
        : '?facility_id=$facilityId';
    final response = await ApiClient.get(
      '/api/atlas/facilities/incoming-bookings/$query',
      auth: true,
    );

    if (response.statusCode != 200) {
      return const [];
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data
        .map((item) => IncomingBooking.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

class FacilityMapper {
  static ParkingLot mapFacility(Map<String, dynamic> facility) {
    final id = facility['id'].toString();
    final availableSpots = (facility['available_spots'] as num?)?.toInt() ?? 0;
    final confidence = (facility['confidence'] as num?)?.toDouble() ?? 80.0;
    final rating = (confidence / 20).clamp(3.5, 5.0);
    final price = (facility['price'] as num?)?.toDouble() ??
        (facility['hourly_rate'] as num?)?.toDouble() ??
        0.0;

    return ParkingLot(
      id: id,
      name: facility['name'] as String? ?? 'Parking Facility',
      address: facility['address'] as String? ??
          (facility['owner_name'] as String? ?? 'Address unavailable'),
      areaTags: (facility['badges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
      latitude: (facility['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (facility['longitude'] as num?)?.toDouble() ?? 0.0,
      pricePerHour: price,
      rating: rating,
      reviewCount: (facility['review_count'] as num?)?.toInt() ?? 0,
      distance: facility['distance']?.toString() ?? '0.0 mi',
      availabilityLabel: '$availableSpots spots',
      isOpen: availableSpots > 0,
      imageAsset: 'assets/images/garage_header.svg',
      amenities: const [],
      floors: const [],
      requiresApproval: facility['requires_approval'] as bool? ?? false,
      ownerName: facility['owner_name'] as String?,
    );
  }
}
