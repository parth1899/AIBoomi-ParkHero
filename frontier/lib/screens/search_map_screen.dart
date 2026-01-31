import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../components/parking_card.dart';
import '../components/parking_details_sheet.dart';
import '../data/dummy_data.dart';
import '../navigation/app_routes.dart';
import '../theme/app_theme.dart';
import '../utils/location_utils.dart';
import '../types/models.dart';

class SearchMapScreen extends StatefulWidget {
  final String label;
  final double latitude;
  final double longitude;

  const SearchMapScreen({
    super.key,
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<SearchMapScreen> createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<SearchMapScreen> {
  MapboxMap? _mapboxMap;
  CircleAnnotationManager? _circleManager;

  @override
  void dispose() {
    _circleManager?.deleteAll();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _circleManager = await mapboxMap.annotations.createCircleAnnotationManager();
    await _renderLots();
  }

  Future<void> _renderLots() async {
    final manager = _circleManager;
    if (manager == null) return;
    await manager.deleteAll();
    for (final lot in _nearbyLots) {
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

  List<ParkingLot> _nearbyLots = [];

  @override
  void initState() {
    super.initState();
    _nearbyLots = parkingLots
        .where(
          (lot) =>
              LocationUtils.distanceInKm(
                lat1: widget.latitude,
                lon1: widget.longitude,
                lat2: lot.latitude,
                lon2: lot.longitude,
              ) <=
              5.0,
        )
        .toList();

    if (_nearbyLots.isEmpty) {
      _nearbyLots = List.of(parkingLots);
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
      ),
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey('search_map'),
            onMapCreated: _onMapCreated,
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(widget.longitude, widget.latitude),
              ),
              zoom: 13.0,
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
                          const Text('Nearby Parking', style: AppTextStyles.subtitle),
                          const SizedBox(height: AppSpacing.md),
                          ..._nearbyLots.map(
                            (lot) => ParkingCard(
                              lot: lot,
                              onTap: () => _showLotDetails(lot),
                            ),
                          ),
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
