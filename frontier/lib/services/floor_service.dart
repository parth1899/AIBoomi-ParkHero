import 'dart:convert';

import '../config/api_config.dart';
import '../types/models.dart';
import 'api_client.dart';

class FloorService {
  static Future<ParkingFloor?> fetchFloorMap(String floorId) async {
    final response = await ApiClient.get('/api/mobile/floors/$floorId/map/');
    if (response.statusCode != 200) {
      return null;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final spots = (data['spots'] as List<dynamic>? ?? [])
        .map((spot) => _mapSpot(spot as Map<String, dynamic>))
        .toList();

    final imagePath = data['floorplan_image'] as String?;
    final imageUrl = _resolveImageUrl(imagePath);

    return ParkingFloor(
      id: data['id'].toString(),
      apiId: data['id'].toString(),
      name: data['label'] as String? ?? 'Level',
      imageAsset: 'assets/images/floor_map.svg',
      imageUrl: imageUrl,
      spots: spots,
    );
  }

  static String? _resolveImageUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('/')) {
      return '$apiBaseUrl$value';
    }
    return '$apiBaseUrl/$value';
  }

  static ParkingSpot _mapSpot(Map<String, dynamic> data) {
    final x = (data['x'] as num?)?.toDouble() ?? 0.5;
    final y = (data['y'] as num?)?.toDouble() ?? 0.5;
    final normalizedX = x > 1 ? x / 100 : x;
    final normalizedY = y > 1 ? y / 100 : y;

    return ParkingSpot(
      id: data['id'].toString(),
      label: data['code'] as String? ?? 'S',
      x: normalizedX,
      y: normalizedY,
      status: _mapSpotStatus(data['status']?.toString()),
      pricePerHour: (data['price'] as num?)?.toDouble() ?? 4.0,
    );
  }

  static SpotStatus _mapSpotStatus(String? status) {
    switch (status) {
      case 'occupied':
        return SpotStatus.occupied;
      case 'reserved':
        return SpotStatus.reserved;
      case 'available':
      default:
        return SpotStatus.available;
    }
  }
}
