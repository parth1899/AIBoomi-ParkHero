import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../types/models.dart';

class SpotMarker extends StatelessWidget {
  final ParkingSpot spot;
  final bool selected;
  final VoidCallback? onTap;

  const SpotMarker({
    super.key,
    required this.spot,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus(spot.status, selected);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              spot.label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (spot.status == SpotStatus.available) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.check_circle,
                size: 12,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _colorForStatus(SpotStatus status, bool selected) {
    if (selected) {
      return AppColors.primary;
    }
    switch (status) {
      case SpotStatus.available:
        return AppColors.teal;
      case SpotStatus.occupied:
        return AppColors.textSecondary;
      case SpotStatus.reserved:
        return AppColors.primary;
    }
  }
}
