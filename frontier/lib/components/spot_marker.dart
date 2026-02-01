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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24), // Pill shape
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: selected 
            ? Border.all(color: Colors.white, width: 1.5) 
            : null,
        ),
        child: Text(
          spot.label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
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
