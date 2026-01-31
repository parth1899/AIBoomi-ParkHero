import 'dart:convert';

import '../data/dummy_data.dart';
import '../types/models.dart';
import 'api_client.dart';

class FacilityService {
  static List<ParkingLot> _cache = [];

  static List<ParkingLot> get cachedFacilities => _cache;

  static Future<List<ParkingLot>> fetchFacilities({
    String? type,
    String? facilityType,
  }) async {
    final queryParams = <String, String>{};
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }
    if (facilityType != null && facilityType.isNotEmpty) {
      queryParams['facility_type'] = facilityType;
    }

    final uri = Uri(
      path: '/api/mobile/facilities/',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final response = await ApiClient.get(uri.toString());
    if (response.statusCode != 200) {
      return _cache.isNotEmpty ? _cache : parkingLots;
    }

    final decoded = json.decode(response.body);
    final list = _extractList(decoded);
    final facilities = list
      .map((item) => _mapFacility(item as Map<String, dynamic>))
      .toList();
    _cache = facilities;
    return facilities;
  }

  static Future<ParkingLot?> fetchFacilityDetail(String id) async {
    final response = await ApiClient.get('/api/mobile/facilities/$id/');
    if (response.statusCode != 200) {
      return null;
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return _mapFacility(data, includeFloors: true);
  }

  static ParkingLot _mapFacility(
    Map<String, dynamic> facility, {
    bool includeFloors = false,
  }) {
    final id = facility['id'].toString();
    final availableSpots = _parseNum(facility['available_spots'])?.toInt() ?? 0;
    final confidence = _parseNum(facility['confidence']) ?? 80.0;
    final rating = (confidence / 20).clamp(3.5, 5.0);
    final price = _parseNum(facility['price']) ??
      _parseNum(facility['hourly_rate']) ??
        0.0;

    final floors = includeFloors
        ? _mapFloors((facility['floors'] as List<dynamic>?) ?? [])
        : const <ParkingFloor>[];

    final lat = _parseNum(facility['latitude']) ??
      _parseNum(facility['latitute']) ??
      0.0;
    final lng = _parseNum(facility['longitude']) ?? 0.0;

    return ParkingLot(
      id: id,
      name: facility['name'] as String? ?? 'Parking Facility',
      address: facility['address'] as String? ??
        (facility['owner_name'] as String? ?? 'Address unavailable'),
      areaTags: (facility['badges'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
        <String>[],
      latitude: lat,
      longitude: lng,
      pricePerHour: price,
      rating: rating,
      reviewCount: _parseNum(facility['review_count'])?.toInt() ?? 120,
      distance: facility['distance']?.toString() ?? '0.0 mi',
      availabilityLabel: '$availableSpots spots',
      isOpen: availableSpots > 0,
      imageAsset: 'assets/images/garage_header.svg',
      amenities: _fallbackAmenities(),
      floors: floors,
      requiresApproval: facility['requires_approval'] as bool? ?? false,
      ownerName: facility['owner_name'] as String?,
    );
  }

  static List<ParkingAmenity> _fallbackAmenities() {
    return const [
      amenityCctv,
      amenityCovered,
      amenityAccessible,
    ];
  }

  static List<ParkingFloor> _mapFloors(List<dynamic> floors) {
    if (floors.isEmpty) {
      return const [];
    }

    return floors.map((floor) {
      final data = floor as Map<String, dynamic>;
      return ParkingFloor(
        id: data['id'].toString(),
        apiId: data['id'].toString(),
        name: data['label'] as String? ?? 'Level',
        imageAsset: 'assets/images/floor_map.svg',
        spots: const [],
        availableSpots: _parseNum(data['available_spots'])?.toInt(),
        totalSpots: _parseNum(data['total_spots'])?.toInt(),
      );
    }).toList();
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

  static double? _parseNum(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
