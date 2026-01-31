import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../components/amenity_chip.dart';
import '../components/info_tile.dart';
import '../components/primary_button.dart';
import '../navigation/app_routes.dart';
import '../theme/app_theme.dart';
import '../types/models.dart';

class ParkingDetailScreen extends StatelessWidget {
  final ParkingLot lot;

  const ParkingDetailScreen({
    super.key,
    required this.lot,
  });

  @override
  Widget build(BuildContext context) {
    final floor = _getFloorForLot(lot);
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 280,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      SvgPicture.asset(
                        lot.imageAsset,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                        bottom: AppSpacing.lg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lot.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    lot.address,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'HOURLY RATE',
                                    style: AppTextStyles.caption,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        '\$${lot.pricePerHour.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        '/hr',
                                        style: AppTextStyles.body,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(AppRadii.md),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    lot.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.star, size: 14, color: AppColors.success),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${lot.reviewCount} reviews',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              label: 'Get Directions',
                              icon: Icons.directions,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.navigation,
                                arguments: lot,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _ActionButton(
                              label: 'Call Support',
                              icon: Icons.call,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ActionButton(
                        label: 'View Floor Map',
                        icon: Icons.layers,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.floorMap,
                          arguments: floor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            InfoTile(
                              icon: Icons.access_time,
                              title: 'Open 24 Hours',
                              subtitle: 'Operating Hours',
                              trailing: lot.isOpen ? 'Open Now' : 'Closed',
                              trailingColor: lot.isOpen
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                            InfoTile(
                              icon: Icons.navigation,
                              title: '${lot.distance} miles away',
                              subtitle: 'Distance from you',
                              trailing: '4 min walk',
                              trailingColor: AppColors.textSecondary,
                            ),
                            const InfoTile(
                              icon: Icons.info_outline,
                              title: 'Information',
                              subtitle:
                                  'Secure, covered parking located in the heart of the business district. Easy elevator access to shopping malls.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text('Amenities', style: AppTextStyles.subtitle),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: lot.amenities
                            .map((amenity) => AmenityChip(amenity: amenity))
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
            child: PrimaryButton(
              label: 'Book Spot for \$${lot.pricePerHour.toStringAsFixed(2)}',
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.floorMap,
                arguments: floor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ParkingFloor _getFloorForLot(ParkingLot lot) {
    if (lot.floors.isNotEmpty) {
      return lot.floors.first;
    }
    return ParkingFloor(
      id: '${lot.id}-fallback',
      name: 'Level P1',
      imageAsset: 'assets/images/floor_map.svg',
      spots: const [
        ParkingSpot(
          id: 'A1',
          label: 'A1',
          x: 0.2,
          y: 0.35,
          status: SpotStatus.available,
          pricePerHour: 4.0,
        ),
        ParkingSpot(
          id: 'A2',
          label: 'A2',
          x: 0.45,
          y: 0.32,
          status: SpotStatus.reserved,
          pricePerHour: 4.0,
        ),
        ParkingSpot(
          id: 'A3',
          label: 'A3',
          x: 0.7,
          y: 0.34,
          status: SpotStatus.occupied,
          pricePerHour: 4.0,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
