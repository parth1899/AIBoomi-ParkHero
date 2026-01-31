import 'dart:convert';

import '../types/models.dart';
import 'api_client.dart';

class AtlasService {
  static Future<List<ParkingFloor>> fetchFacilityFloorsWithSpots({
    required String facilityId,
    String? spotStatus,
  }) async {
    final floorsUri = Uri(
      path: '/api/atlas/floors/',
      queryParameters: {'facility': facilityId},
    );
    final floorsResponse = await ApiClient.get(floorsUri.toString());
    if (floorsResponse.statusCode != 200) {
      return const [];
    }

    final floorsDecoded = json.decode(floorsResponse.body);
    final floorsList = _extractList(floorsDecoded);
    if (floorsList.isEmpty) return const [];

    final floors = <ParkingFloor>[];
    for (final item in floorsList) {
      final floor = item as Map<String, dynamic>;
      final floorId = floor['id'].toString();

      final spotsQuery = <String, String>{'floor': floorId};
      if (spotStatus != null && spotStatus.isNotEmpty) {
        spotsQuery['status'] = spotStatus;
      }
      final spotsUri = Uri(
        path: '/api/atlas/spots/',
        queryParameters: spotsQuery,
      );
      final spotsResponse = await ApiClient.get(spotsUri.toString());
      final spots = spotsResponse.statusCode == 200
          ? _mapSpotsWithGrid(
              _extractList(json.decode(spotsResponse.body)),
            )
          : const <ParkingSpot>[];

      floors.add(
        ParkingFloor(
          id: floorId,
          apiId: floorId,
          name: floor['label'] as String? ?? 'Level',
          imageAsset: 'assets/images/floor_map.svg',
          spots: spots,
          totalSpots: _parseNum(floor['spots_count'])?.toInt() ??
              _parseNum(floor['total_spots'])?.toInt(),
          availableSpots: _parseNum(floor['available_count'])?.toInt() ??
              _parseNum(floor['available_spots'])?.toInt(),
        ),
      );
    }

    return floors;
  }

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
      facilityType: facility['type']?.toString(),
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

List<dynamic> _extractList(dynamic decoded) {
  if (decoded is List) return decoded;
  if (decoded is Map<String, dynamic>) {
    final results = decoded['results'];
    if (results is List) return results;
    final data = decoded['data'];
    if (data is List) return data;
  }
  return const [];
}

double? _parseNum(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

List<ParkingSpot> _mapSpotsWithGrid(List<dynamic> items) {
  if (items.isEmpty) return const [];
  final total = items.length;
  const columns = 6;
  final rows = (total / columns).ceil();

  return items.asMap().entries.map((entry) {
    final index = entry.key;
    final data = entry.value as Map<String, dynamic>;
    final col = index % columns;
    final row = index ~/ columns;
    final x = (col + 1) / (columns + 1);
    final y = (row + 1) / (rows + 1);

    return ParkingSpot(
      id: data['id'].toString(),
      label: data['code'] as String? ?? data['label'] as String? ?? 'S',
      x: x,
      y: y,
      status: _mapSpotStatus(data['status']?.toString()),
      pricePerHour: _parseNum(data['price']) ??
          _parseNum(data['hourly_rate']) ??
          0.0,
    );
  }).toList();
}

SpotStatus _mapSpotStatus(String? status) {
  switch (status) {
    case 'occupied':
      return SpotStatus.occupied;
    case 'blocked':
      return SpotStatus.reserved;
    case 'reserved':
      return SpotStatus.reserved;
    case 'available':
    default:
      return SpotStatus.available;
  }
}
