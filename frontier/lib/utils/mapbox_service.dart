import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/mapbox_config.dart';

class MapboxPlace {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const MapboxPlace({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class MapboxRoute {
  final List<List<double>> coordinates;
  final double distanceMeters;
  final double durationSeconds;

  const MapboxRoute({
    required this.coordinates,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

class MapboxService {
  static const _baseGeocodingUrl =
      'https://api.mapbox.com/geocoding/v5/mapbox.places';
  static const _baseDirectionsUrl =
      'https://api.mapbox.com/directions/v5/mapbox/driving';

  static Future<List<MapboxPlace>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
      '$_baseGeocodingUrl/${Uri.encodeComponent(query)}.json?limit=6&access_token=$mapboxAccessToken',
    );
    final response = await http.get(url);
    if (response.statusCode != 200) {
      return [];
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final features = (data['features'] as List<dynamic>?) ?? [];
    return features.map((feature) {
      final props = feature as Map<String, dynamic>;
      final placeName = props['text'] as String? ?? 'Unknown';
      final address = props['place_name'] as String? ?? '';
      final center = (props['center'] as List<dynamic>?) ?? [0, 0];
      final lon = (center[0] as num).toDouble();
      final lat = (center[1] as num).toDouble();
      return MapboxPlace(
        name: placeName,
        address: address,
        latitude: lat,
        longitude: lon,
      );
    }).toList();
  }

  static Future<MapboxRoute?> getRoute({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) async {
    final url = Uri.parse(
      '$_baseDirectionsUrl/$startLon,$startLat;$endLon,$endLat?geometries=geojson&overview=full&access_token=$mapboxAccessToken',
    );
    final response = await http.get(url);
    if (response.statusCode != 200) {
      return null;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final routes = (data['routes'] as List<dynamic>?) ?? [];
    if (routes.isEmpty) return null;

    final route = routes.first as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>;
    final coords = (geometry['coordinates'] as List<dynamic>)
        .map((item) => (item as List<dynamic>)
            .map((v) => (v as num).toDouble())
            .toList())
        .toList();

    return MapboxRoute(
      coordinates: coords,
      distanceMeters: (route['distance'] as num).toDouble(),
      durationSeconds: (route['duration'] as num).toDouble(),
    );
  }
}
