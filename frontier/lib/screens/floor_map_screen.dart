import 'dart:ui';
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
    // Priority: 1. AtlasService (Facilities API), 2. FloorService, 3. Mock
    List<ParkingFloor> floors = const [];
    ParkingFloor? remoteFloor;
    
    if (lot.id.isNotEmpty) {
      floors = await AtlasService.fetchFacilityFloorsWithSpots(
        facilityId: lot.id,
      );
    }

    if (floors.isEmpty && _floor.apiId != null) {
      remoteFloor = await FloorService.fetchFloorMap(_floor.apiId!);
    }

    // Fallback to mock if API failed and it looks like a mall or we have no data
    if (floors.isEmpty && remoteFloor == null && _isMall(lot)) {
      floors = _buildMockMallFloors(lot);
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
      body: Column(
        children: [
          _FloorSelector(
            floors: _floors,
            selectedIndex: _selectedFloorIndex,
            onSelect: (index) {
              setState(() {
                _selectedFloorIndex = index;
                _floor = _floors[index];
                _selectedSpot = _pickInitialSpot(_floor);
              });
            },
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _ParkingLotList(
                    spots: _floor.spots,
                    selectedSpotId: _selectedSpot?.id,
                    onSpotSelected: (spot) {
                      setState(() => _selectedSpot = spot);
                    },
                  ),
          ),
          _SelectionDetailsBar(
            floorName: _floor.name,
            selectedSpot: _selectedSpot,
            onReserve: () => _showHourPicker(context, lot),
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final total = spot.pricePerHour * _hours;
            final now = DateTime.now();
            final endTime = now.add(Duration(hours: _hours));
            final endStr = '${endTime.hour > 12 ? endTime.hour - 12 : endTime.hour}:${endTime.minute.toString().padLeft(2, '0')} ${endTime.hour >= 12 ? 'PM' : 'AM'}';

            return Container(
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text('Schedule Booking', style: AppTextStyles.title),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.8),
                              Colors.white.withOpacity(0.4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          border: Border.all(color: Colors.white.withOpacity(0.6)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('DURATION', style: AppTextStyles.caption),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (_hours > 1) {
                                          setModalState(() => _hours--);
                                          setState(() {});
                                        }
                                      },
                                      child: const Icon(Icons.remove_circle, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '$_hours hrs',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () {
                                        if (_hours < 24) {
                                          setModalState(() => _hours++);
                                          setState(() {});
                                        }
                                      },
                                      child: const Icon(Icons.add_circle, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(width: 1, height: 40, color: AppColors.divider),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('UNTIL', style: AppTextStyles.caption),
                                const SizedBox(height: 4),
                                Text(
                                  endStr,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: AppTextStyles.subtitle),
                          Text(
                            '₹${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: 'Confirm Booking',
                          onPressed: () async {
                            final booking = await BookingService.createBooking(
                              facilityId: int.tryParse(lot.id) ?? 0,
                              durationHours: _hours.toDouble(),
                            );
                            if (!mounted) return;
                            Navigator.pop(context);
                            if (booking != null) {
                              final fullBooking = booking.copyWith(
                                latitude: lot.latitude,
                                longitude: lot.longitude,
                              );
                              Navigator.pushNamed(
                                context,
                                AppRoutes.bookingConfirmation,
                                arguments: fullBooking,
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
                      ),
                    ],
                  ),
                ),
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

class _ParkingLotList extends StatelessWidget {
  final List<ParkingSpot> spots;
  final String? selectedSpotId;
  final Function(ParkingSpot) onSpotSelected;

  const _ParkingLotList({
    required this.spots,
    required this.selectedSpotId,
    required this.onSpotSelected,
  });

  Map<String, List<ParkingSpot>> _groupSpots(List<ParkingSpot> allSpots) {
    final groups = <String, List<ParkingSpot>>{};
    for (var spot in allSpots) {
      String groupName = 'General';
      final parts = spot.label.split('-');
      if (parts.length > 1) {
        final lastPart = parts.last;
        final match = RegExp(r'^([A-Z]+)\d*').firstMatch(lastPart);
        if (match != null) {
          groupName = 'Row ${match.group(1)}';
        } else {
           if (parts.length == 2 && int.tryParse(parts.last) != null) {
              groupName = 'Section ${parts.first}';
           }
        }
      } else {
         final match = RegExp(r'^([A-Z]+)').firstMatch(spot.label);
         if (match != null) {
            groupName = 'Row ${match.group(1)}';
         }
      }
      groups.putIfAbsent(groupName, () => []).add(spot);
    }
    
    final sortedKeys = groups.keys.toList()..sort();
    return Map.fromEntries(sortedKeys.map((k) => MapEntry(k, groups[k]!)));
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupSpots(spots);
    
    if (grouped.isEmpty) {
       return const Center(child: Text('No spots available on this floor.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
      itemCount: grouped.length,
      separatorBuilder: (c, i) => const SizedBox(height: AppSpacing.xl),
      itemBuilder: (context, index) {
        final groupName = grouped.keys.elementAt(index);
        final groupSpots = grouped[groupName]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              groupName,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: groupSpots.map((spot) {
                return SpotMarker(
                  spot: spot,
                  selected: spot.id == selectedSpotId,
                  onTap: () => onSpotSelected(spot),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _FloorSelector extends StatelessWidget {
  final List<ParkingFloor> floors;
  final int selectedIndex;
  final Function(int) onSelect;

  const _FloorSelector({
     required this.floors,
     required this.selectedIndex,
     required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
             color: Colors.black.withOpacity(0.05),
             offset: const Offset(0, 4),
             blurRadius: 10,
          )
        ]
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: floors.asMap().entries.map((entry) {
             final index = entry.key;
             final floor = entry.value;
             return _LevelChip(
               label: floor.name,
               selected: index == selectedIndex,
               onTap: () => onSelect(index),
             );
          }).toList(),
        ),
      ),
    );
  }
}

class _SelectionDetailsBar extends StatelessWidget {
  final String floorName;
  final ParkingSpot? selectedSpot;
  final VoidCallback onReserve;

  const _SelectionDetailsBar({
    required this.floorName,
    required this.selectedSpot,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
           BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
           )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
             Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendDot(color: AppColors.teal, label: 'Available'),
                  const SizedBox(width: 24),
                  _LegendDot(color: AppColors.textSecondary, label: 'Occupied'),
                  const SizedBox(width: 24),
                  _LegendDot(color: AppColors.primary, label: 'Selected'),
                ],
             ),
             const SizedBox(height: AppSpacing.lg),
             Row(
                children: [
                   Expanded(
                      child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text(
                               selectedSpot != null ? 'Spot ${selectedSpot!.label}' : 'Select a spot',
                               style: AppTextStyles.subtitle,
                            ),
                            const SizedBox(height: 4),
                            Text(floorName, style: AppTextStyles.caption),
                         ],
                      ),
                   ),
                   if (selectedSpot != null)
                     Text(
                        '₹${selectedSpot!.pricePerHour.toStringAsFixed(2)}/hr',
                        style: const TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.w700,
                           color: AppColors.primary,
                        ),
                     ),
                ],
             ),
             const SizedBox(height: AppSpacing.lg),
             SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                   label: 'Reserve Spot',
                   onPressed: selectedSpot != null && selectedSpot!.status == SpotStatus.available ? onReserve : null,
                ),
             )
          ],
        ),
      ),
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
