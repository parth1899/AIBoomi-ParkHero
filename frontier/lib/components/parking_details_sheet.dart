import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../types/models.dart';

class ParkingDetailsSheet extends StatelessWidget {
  final ParkingLot lot;
  final VoidCallback? onViewDetails;
  final VoidCallback? onGetDirections;

  const ParkingDetailsSheet({
    super.key,
    required this.lot,
    this.onViewDetails,
    this.onGetDirections,
  });

  int _parseRemainingSpots(String label) {
    final digits = RegExp(r'\d+').firstMatch(label);
    if (digits == null) return 18;
    return int.tryParse(digits.group(0) ?? '') ?? 18;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _parseRemainingSpots(lot.availabilityLabel);
    final levels = lot.floors.isEmpty ? 3 : lot.floors.length;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(lot.name, style: AppTextStyles.subtitle),
          const SizedBox(height: 4),
          Text(lot.address, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _DetailPill(
                label: 'Remaining',
                value: '$remaining spots',
              ),
              const SizedBox(width: AppSpacing.sm),
              _DetailPill(
                label: 'Levels',
                value: '$levels',
              ),
              const SizedBox(width: AppSpacing.sm),
              _DetailPill(
                label: 'Rate',
                value: '\$${lot.pricePerHour.toStringAsFixed(2)}/hr',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onGetDirections,
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.info_outline),
                  label: const Text('View Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  final String label;
  final String value;

  const _DetailPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
