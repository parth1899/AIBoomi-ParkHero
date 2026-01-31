import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../components/app_glass_card.dart';
import '../components/parking_card.dart';
import '../components/parking_search_delegate.dart';
import '../components/parking_details_sheet.dart';
import '../data/dummy_data.dart';
import '../navigation/app_routes.dart';
import '../theme/app_theme.dart';
import '../types/models.dart';
import '../utils/mapbox_service.dart';
import '../utils/location_utils.dart';
import '../services/facility_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MapboxMap? _mapboxMap;
  CircleAnnotationManager? _circleManager;
  PolylineAnnotationManager? _lineManager;
  geo.Position? _currentPosition;
  bool _availableOnly = true;
  double _radiusKm = 3.0;
  List<ParkingLot> _allLots = [];
  List<ParkingLot> _visibleLots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    final lots = await FacilityService.fetchFacilities();
    if (!mounted) return;
    setState(() {
      _allLots = lots;
      _loading = false;
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _circleManager?.deleteAll();
    _lineManager?.deleteAll();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _circleManager = await mapboxMap.annotations.createCircleAnnotationManager();
    _lineManager = await mapboxMap.annotations.createPolylineAnnotationManager();
    await mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );
    final lotsToRender = _visibleLots.isNotEmpty ? _visibleLots : parkingLots;
    await _addParkingMarkers(lotsToRender);
  }

  Future<void> _addParkingMarkers(List<ParkingLot> lots) async {
    final manager = _circleManager;
    if (manager == null) return;
    await manager.deleteAll();
    for (final lot in lots) {
      await manager.create(
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(lot.longitude, lot.latitude),
          ),
          circleColor: lot.isOpen ? AppColors.teal.value : AppColors.textSecondary.value,
          circleRadius: 8.0,
          circleStrokeColor: Colors.white.value,
          circleStrokeWidth: 2.0,
        ),
      );
    }
  }

  Future<void> _drawRouteToLot(ParkingLot lot) async {
    final position = _currentPosition ?? await LocationUtils.getCurrentPosition();
    if (position == null || _lineManager == null) return;

    final route = await MapboxService.getRoute(
      startLat: position.latitude,
      startLon: position.longitude,
      endLat: lot.latitude,
      endLon: lot.longitude,
    );
    if (route == null) return;

    await _lineManager!.deleteAll();
    await _lineManager!.create(
      PolylineAnnotationOptions(
        geometry: LineString(
          coordinates: route.coordinates
              .map((coord) => Position(coord[0], coord[1]))
              .toList(),
        ),
        lineColor: AppColors.primary.value,
        lineWidth: 4.0,
        lineOpacity: 0.8,
      ),
    );
  }

  Future<void> _fetchCurrentLocation() async {
    final position = await LocationUtils.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _currentPosition = position;
      _applyFilters();
    });

    if (position != null && _mapboxMap != null) {
      _mapboxMap!.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: 13.4,
        ),
      );
    }
  }

  void _applyFilters() {
    final position = _currentPosition;
    List<ParkingLot> lots = _allLots.isNotEmpty
        ? List.of(_allLots)
        : List.of(parkingLots);

    if (_availableOnly) {
      lots = lots.where((lot) => lot.isOpen).toList();
    }

    if (position != null) {
      lots = lots
          .where((lot) {
            if (lot.latitude == 0.0 && lot.longitude == 0.0) {
              return true;
            }
            final distance = LocationUtils.distanceInKm(
              lat1: position.latitude,
              lon1: position.longitude,
              lat2: lot.latitude,
              lon2: lot.longitude,
            );
            return distance <= _radiusKm;
          })
          .toList();
    }

    _visibleLots = lots;
    _addParkingMarkers(_visibleLots);
  }

  void _showLotDetails(ParkingLot lot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ParkingDetailsSheet(
        lot: lot,
        onGetDirections: () {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            AppRoutes.navigation,
            arguments: lot,
          );
        },
        onViewDetails: () {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            AppRoutes.parkingDetail,
            arguments: lot,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fallbackLots = _allLots.isNotEmpty ? _allLots : parkingLots;
    final featuredLot = _visibleLots.isNotEmpty
      ? _visibleLots.first
      : fallbackLots.first;
    final lotsToShow = _visibleLots.isNotEmpty ? _visibleLots : fallbackLots;

    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey('home_map'),
            onMapCreated: _onMapCreated,
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(
                  featuredLot.longitude,
                  featuredLot.latitude,
                ),
              ),
              zoom: 13.2,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      AppGlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        borderRadius: AppRadii.md,
                        child: const Icon(Icons.arrow_back, size: 18),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showSearch(
                              context: context,
                              delegate: ParkingSearchDelegate(),
                            );
                          },
                          child: AppGlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            borderRadius: AppRadii.md,
                            child: Row(
                              children: [
                                const Icon(Icons.search, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Search area or address',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppGlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        borderRadius: AppRadii.md,
                        child: const Icon(Icons.tune, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppGlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      borderRadius: AppRadii.md,
                      child: GestureDetector(
                        onTap: _fetchCurrentLocation,
                        child: const Icon(Icons.my_location, size: 18),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            minChildSize: 0.18,
            initialChildSize: 0.26,
            maxChildSize: 0.55,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadii.xl),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 52,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        children: [
                          const Text(
                            'Nearby Parking',
                            style: AppTextStyles.subtitle,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (_loading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else ...[ 
                            if (lotsToShow.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text('No nearby parking found.'),
                              ),
                            ...lotsToShow.map(
                              (lot) => ParkingCard(
                                lot: lot,
                                onTap: () => _showLotDetails(lot),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

