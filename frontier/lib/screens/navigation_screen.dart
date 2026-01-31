import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../theme/app_theme.dart';
import '../types/models.dart';
import '../utils/location_utils.dart';
import '../utils/mapbox_service.dart';

class NavigationScreen extends StatefulWidget {
  final ParkingLot lot;

  const NavigationScreen({super.key, required this.lot});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  MapboxMap? _mapboxMap;
  PolylineAnnotationManager? _lineManager;
  geo.Position? _current;
  MapboxRoute? _route;

  @override
  void dispose() {
    _lineManager?.deleteAll();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _lineManager = await mapboxMap.annotations.createPolylineAnnotationManager();
    await mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );
    await _buildRoute();
  }

  Future<void> _buildRoute() async {
    final position = await LocationUtils.getCurrentPosition();
    if (!mounted) return;
    setState(() => _current = position);
    if (_lineManager == null) return;

    final startLat = position?.latitude ?? (widget.lot.latitude + 0.01);
    final startLon = position?.longitude ?? (widget.lot.longitude - 0.01);

    final route = await MapboxService.getRoute(
      startLat: startLat,
      startLon: startLon,
      endLat: widget.lot.latitude,
      endLon: widget.lot.longitude,
    );
    final resolvedRoute = route ?? _buildFallbackRoute(
      startLat: startLat,
      startLon: startLon,
      endLat: widget.lot.latitude,
      endLon: widget.lot.longitude,
    );
    setState(() => _route = resolvedRoute);

    await _lineManager!.deleteAll();
    await _lineManager!.create(
      PolylineAnnotationOptions(
        geometry: LineString(
          coordinates: resolvedRoute.coordinates
              .map((coord) => Position(coord[0], coord[1]))
              .toList(),
        ),
        lineColor: AppColors.primary.value,
        lineWidth: 5.0,
        lineOpacity: 0.85,
      ),
    );

    _mapboxMap?.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(widget.lot.longitude, widget.lot.latitude),
        ),
        zoom: 13.0,
      ),
    );
  }

  MapboxRoute _buildFallbackRoute({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) {
    final distanceKm = LocationUtils.distanceInKm(
      lat1: startLat,
      lon1: startLon,
      lat2: endLat,
      lon2: endLon,
    );
    final distanceMeters = distanceKm * 1000;
    final durationSeconds = (distanceMeters / 12.5).roundToDouble();
    return MapboxRoute(
      coordinates: [
        [startLon, startLat],
        [endLon, endLat],
      ],
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = _route?.durationSeconds ?? 0;
    final minutes = duration == 0 ? '--' : (duration / 60).round().toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey('nav_map'),
            onMapCreated: _onMapCreated,
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(widget.lot.longitude, widget.lot.latitude),
              ),
              zoom: 12.6,
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.navigation, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lot.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _current == null
                              ? 'Locating you...'
                              : '$minutes min drive',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _buildRoute,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
