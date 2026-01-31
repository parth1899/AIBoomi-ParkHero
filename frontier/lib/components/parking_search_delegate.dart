import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../navigation/app_routes.dart';
import '../theme/app_theme.dart';
import '../utils/mapbox_service.dart';

class ParkingSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Search area or address';

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResults(context);
  }

  Widget _buildResults(BuildContext context) {
    final normalized = query.toLowerCase();
    final local = parkingLots
        .where(
          (lot) =>
              lot.name.toLowerCase().contains(normalized) ||
              lot.address.toLowerCase().contains(normalized) ||
              lot.areaTags.any(
                (tag) => tag.toLowerCase().contains(normalized),
              ),
        )
        .toList();

    return FutureBuilder<List<MapboxPlace>>(
      future: MapboxService.searchPlaces(query),
      builder: (context, snapshot) {
        final places = snapshot.data ?? [];
        final hasAny = local.isNotEmpty || places.isNotEmpty;
        if (!hasAny) {
          return const Center(child: Text('No results'));
        }

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (local.isNotEmpty) ...[
              const Text('Parking lots', style: AppTextStyles.subtitle),
              const SizedBox(height: AppSpacing.sm),
              ...local.map(
                (lot) => ListTile(
                  title: Text(lot.name),
                  subtitle: Text(lot.address),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    close(context, null);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.parkingDetail,
                      arguments: lot,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (places.isNotEmpty) ...[
              const Text('Places', style: AppTextStyles.subtitle),
              const SizedBox(height: AppSpacing.sm),
              ...places.map(
                (place) => ListTile(
                  title: Text(place.name),
                  subtitle: Text(place.address),
                  trailing: const Icon(Icons.near_me, size: 14),
                  onTap: () {
                    close(context, null);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.searchMap,
                      arguments: {
                        'label': place.name,
                        'lat': place.latitude,
                        'lon': place.longitude,
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
