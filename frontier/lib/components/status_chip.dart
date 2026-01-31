import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../types/models.dart';

class StatusChip extends StatelessWidget {
  final BookingStatus status;

  const StatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus(status);
    final label = _labelForStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Color _colorForStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.reserved:
        return AppColors.primary;
      case BookingStatus.active:
        return AppColors.primary;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.textSecondary;
      case BookingStatus.rejected:
        return AppColors.danger;
    }
  }

  String _labelForStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'PENDING';
      case BookingStatus.reserved:
        return 'RESERVED';
      case BookingStatus.active:
        return 'ACTIVE';
      case BookingStatus.completed:
        return 'COMPLETED';
      case BookingStatus.cancelled:
        return 'CANCELLED';
      case BookingStatus.rejected:
        return 'REJECTED';
    }
  }
}
