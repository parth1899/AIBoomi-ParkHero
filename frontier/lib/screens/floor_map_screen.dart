import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../components/primary_button.dart';
import '../components/spot_marker.dart';
import '../navigation/app_routes.dart';
import '../theme/app_theme.dart';
import '../types/models.dart';
import '../services/floor_service.dart';
import '../services/booking_service.dart';
import '../services/atlas_service.dart';

class FloorMapScreen extends StatefulWidget {
  final FloorMapArgs args;

  const FloorMapScreen({
    super.key,
    required this.args,
  });

  @override
  State<FloorMapScreen> createState() => _FloorMapScreenState();
}

class _FloorMapScreenState extends State<FloorMapScreen> {
  ParkingSpot? _selectedSpot;
  int _hours = 2;
  late ParkingFloor _floor;
  List<ParkingFloor> _floors = const [];
  int _selectedFloorIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _floor = widget.args.floor;
    _floors = widget.args.lot.floors.isNotEmpty
        ? widget.args.lot.floors
        : <ParkingFloor>[_floor];
    _selectedFloorIndex = _floors.indexWhere((f) => f.id == _floor.id);
    if (_selectedFloorIndex < 0) _selectedFloorIndex = 0;
    _floor = _floors[_selectedFloorIndex];
    _selectedSpot = _pickInitialSpot(_floor);
    _loadFloorMap();
  }

  Future<void> _loadFloorMap() async {
    final lot = widget.args.lot;
    if (_isMall(lot)) {
      final mockFloors = _buildMockMallFloors(lot);
      if (!mounted) return;
      setState(() {
        _floors = mockFloors;
        _selectedFloorIndex = 0;
        _floor = _floors.first;
        _selectedSpot = _pickInitialSpot(_floor);
        _loading = false;
      });
      return;
    }

    List<ParkingFloor> floors = const [];
    if (lot.id.isNotEmpty) {
      floors = await AtlasService.fetchFacilityFloorsWithSpots(
        facilityId: lot.id,
      );
    }

    ParkingFloor? remoteFloor;
    if (floors.isEmpty && _floor.apiId != null) {
      remoteFloor = await FloorService.fetchFloorMap(_floor.apiId!);
    }
    if (!mounted) return;
    setState(() {
      if (floors.isNotEmpty) {
        _floors = floors;
        _selectedFloorIndex = _floors.indexWhere(
          (f) => f.id == _floor.id || f.apiId == _floor.apiId,
        );
        if (_selectedFloorIndex < 0) _selectedFloorIndex = 0;
        _floor = _floors[_selectedFloorIndex];
      } else {
        _floor = remoteFloor ?? _floor;
      }
      _selectedSpot = _pickInitialSpot(_floor);
      _loading = false;
    });
  }

  ParkingSpot? _pickInitialSpot(ParkingFloor floor) {
    if (floor.spots.isEmpty) return null;
    return floor.spots.firstWhere(
      (spot) => spot.status == SpotStatus.available,
      orElse: () => floor.spots.first,
    );
  }

  bool _isMall(ParkingLot lot) {
    final type = lot.facilityType?.toLowerCase();
    if (type == 'mall' || type == 'shopping_mall') return true;
    return lot.name.toLowerCase().contains('mall');
  }

  List<ParkingFloor> _buildMockMallFloors(ParkingLot lot) {
    final random = Random(lot.id.hashCode);
    final floorLabels = <String>['Ground', 'Level 1', 'Level 2'];
    return floorLabels.asMap().entries.map((entry) {
      final index = entry.key;
      final label = entry.value;
      final columns = 8;
      final rows = 6;
      final total = columns * rows;
      final spots = List.generate(total, (i) {
        final col = i % columns;
        final row = i ~/ columns;
        final x = (col + 1) / (columns + 1);
        final y = (row + 1) / (rows + 1);
        final isAvailable = random.nextDouble() > 0.35;
        final status = isAvailable ? SpotStatus.available : SpotStatus.occupied;
        return ParkingSpot(
          id: '${lot.id}-$index-$i',
          label: '${String.fromCharCode(65 + row)}${col + 1}',
          x: x,
          y: y,
          status: status,
          pricePerHour: lot.pricePerHour,
        );
      });

      final availableCount = spots
          .where((spot) => spot.status == SpotStatus.available)
          .length;

      return ParkingFloor(
        id: '${lot.id}-floor-$index',
        apiId: null,
        name: label,
        imageAsset: 'assets/images/floor_map.svg',
        spots: spots,
        totalSpots: total,
        availableSpots: availableCount,
      );
    }).toList();
  }

  void _reserveSpotLocally(ParkingSpot spot) {
    final updatedSpots = _floor.spots.map((item) {
      if (item.id != spot.id) return item;
      return ParkingSpot(
        id: item.id,
        label: item.label,
        x: item.x,
        y: item.y,
        status: SpotStatus.occupied,
        pricePerHour: item.pricePerHour,
        amenities: item.amenities,
      );
    }).toList();

    final updatedFloor = ParkingFloor(
      id: _floor.id,
      apiId: _floor.apiId,
      name: _floor.name,
      imageAsset: _floor.imageAsset,
      imageUrl: _floor.imageUrl,
      totalSpots: _floor.totalSpots,
      availableSpots: _floor.availableSpots == null
          ? null
          : (_floor.availableSpots! - 1).clamp(0, _floor.availableSpots!),
      spots: updatedSpots,
    );

    final updatedFloors = [..._floors];
    if (_selectedFloorIndex >= 0 && _selectedFloorIndex < updatedFloors.length) {
      updatedFloors[_selectedFloorIndex] = updatedFloor;
    }

    setState(() {
      _floor = updatedFloor;
      _floors = updatedFloors;
      _selectedSpot = updatedSpots.firstWhere(
        (s) => s.id == spot.id,
        orElse: () => spot,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final lot = widget.args.lot;

    return Scaffold(
      appBar: AppBar(
        title: Text('Parking - ${_floor.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    ..._floors.asMap().entries.map((entry) {
                      final index = entry.key;
                      final floor = entry.value;
                      return _LevelChip(
                        label: floor.name,
                        selected: index == _selectedFloorIndex,
                        onTap: () {
                          setState(() {
                            _selectedFloorIndex = index;
                            _floor = _floors[index];
                            _selectedSpot = _pickInitialSpot(_floor);
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                              child: _floor.imageUrl != null
                                  ? Image.network(
                                      _floor.imageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : SvgPicture.asset(
                                      _floor.imageAsset,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          if (_loading)
                            const Center(child: CircularProgressIndicator())
                          else ...[
                            ..._floor.spots.map((spot) {
                              final left = spot.x * constraints.maxWidth;
                              final top = spot.y * constraints.maxHeight;

                              return Positioned(
                                left: left,
                                top: top,
                                child: SpotMarker(
                                  spot: spot,
                                  selected: _selectedSpot?.id == spot.id,
                                  onTap: () {
                                    setState(() => _selectedSpot = spot);
                                  },
                                ),
                              );
                            }),
                          ],
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: Column(
                              children: [
                                _MapAction(icon: Icons.my_location),
                                const SizedBox(height: 10),
                                _MapAction(icon: Icons.layers),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
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
                    blurRadius: 18,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _LegendDot(color: AppColors.teal, label: 'Available'),
                      const SizedBox(width: 16),
                      _LegendDot(
                        color: AppColors.textSecondary,
                        label: 'Occupied',
                      ),
                      const SizedBox(width: 16),
                      _LegendDot(color: AppColors.primary, label: 'Selected'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Spot ${_selectedSpot?.label ?? ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _floor.name,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      Text(
                        '₹${_selectedSpot?.pricePerHour.toStringAsFixed(2) ?? '0.00'} per hour',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Reserve Spot',
                    onPressed: _selectedSpot == null ||
                            _selectedSpot?.status != SpotStatus.available
                        ? null
                        : () => _showHourPicker(context, lot),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHourPicker(BuildContext context, ParkingLot lot) {
    final spot = _selectedSpot;
    if (spot == null) return;

    if (_isMall(lot)) {
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Spot reserved'),
            content: Text(
              'Spot ${spot.label} is temporarily reserved for you.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      _reserveSpotLocally(spot);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final total = spot.pricePerHour * _hours;
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Hours', style: AppTextStyles.subtitle),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_hours > 1) {
                            setModalState(() => _hours--);
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$_hours hrs',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (_hours < 12) {
                            setModalState(() => _hours++);
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      const Spacer(),
                      Text(
                        '₹${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Confirm for ₹${total.toStringAsFixed(2)}',
                    onPressed: () async {
                      final booking = await BookingService.createBooking(
                        facilityId: int.tryParse(lot.id) ?? 0,
                        durationHours: _hours.toDouble(),
                      );
                      if (!mounted) return;
                      Navigator.pop(context);
                      if (booking != null) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.bookingConfirmation,
                          arguments: booking,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Booking failed. Try again.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _LevelChip({
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.textPrimary : AppColors.card,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapAction extends StatelessWidget {
  final IconData icon;

  const _MapAction({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
