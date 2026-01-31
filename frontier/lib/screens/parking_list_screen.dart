import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;

import '../components/app_glass_card.dart';
import '../components/parking_card.dart';
import '../components/parking_search_delegate.dart';
import '../data/dummy_data.dart';
import '../navigation/app_routes.dart';
import '../theme/app_theme.dart';
import '../utils/location_utils.dart';
import '../types/models.dart';

class ParkingListScreen extends StatefulWidget {
  final double? centerLat;
  final double? centerLon;

  const ParkingListScreen({
    super.key,
    this.centerLat,
    this.centerLon,
  });

  @override
  State<ParkingListScreen> createState() => _ParkingListScreenState();
}

class _ParkingListScreenState extends State<ParkingListScreen> {
  geo.Position? _currentPosition;
  bool _availableOnly = true;
  double _radiusKm = 3.0;
  List<ParkingLot> _visibleLots = parkingLots;

  @override
  void initState() {
    super.initState();
    if (widget.centerLat != null && widget.centerLon != null) {
      _applyFilters();
    }
  }

  Future<void> _fetchCurrentLocation() async {
    final position = await LocationUtils.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _currentPosition = position;
      _applyFilters();
    });
  }

  void _applyFilters() {
    final position = _currentPosition;
    final hasSearchCenter = widget.centerLat != null && widget.centerLon != null;
    var lots = List.of(parkingLots);

    if (_availableOnly) {
      lots = lots.where((lot) => lot.isOpen).toList();
    }

    if (position != null || hasSearchCenter) {
      final centerLat = hasSearchCenter ? widget.centerLat! : position!.latitude;
      final centerLon = hasSearchCenter ? widget.centerLon! : position!.longitude;
      lots = lots
          .where((lot) {
            final distance = LocationUtils.distanceInKm(
              lat1: centerLat,
              lon1: centerLon,
              lat2: lot.latitude,
              lon2: lot.longitude,
            );
            return distance <= _radiusKm;
          })
          .toList();
    }

    _visibleLots = lots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Parking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _fetchCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showSearch(
                      context: context,
                      delegate: ParkingSearchDelegate(),
                    );
                  },
                  child: AppGlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 12,
                    ),
                    borderRadius: AppRadii.lg,
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'Search area or address',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(label: 'Nearest', selected: true),
                      _FilterChip(label: 'Price'),
                      _FilterChip(
                        label: 'Available',
                        selected: _availableOnly,
                        onTap: () {
                          setState(() {
                            _availableOnly = !_availableOnly;
                            _applyFilters();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView.builder(
                    itemCount: _visibleLots.length,
                    itemBuilder: (context, index) {
                      final lot = _visibleLots[index];
                      return ParkingCard(
                        lot: lot,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.parkingDetail,
                          arguments: lot,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: AppGlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                borderRadius: AppRadii.lg,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.map_outlined, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Map View',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AppGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: AppRadii.lg,
          color: selected ? AppColors.primary.withOpacity(0.2) : null,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
