import 'package:flutter/material.dart';

import '../components/app_glass_card.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../types/models.dart';
import '../services/facility_service.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  List<ParkingLot> _lots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    final lots = await FacilityService.fetchFacilities();
    if (!mounted) return;
    setState(() {
      _lots = lots.isNotEmpty ? lots : List.of(parkingLots);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            AppGlassCard(
              child: Row(
                children: const [
                  Icon(Icons.storefront, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('Top listings near you', style: AppTextStyles.subtitle),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _lots.length,
                      itemBuilder: (context, index) {
                        final lot = _lots[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
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
                          child: Row(
                            children: [
                              const Icon(Icons.local_parking, color: AppColors.primary),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lot.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(lot.address, style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${lot.pricePerHour.toStringAsFixed(2)}/hr',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}