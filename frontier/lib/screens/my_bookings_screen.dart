import 'package:flutter/material.dart';

import '../components/app_glass_card.dart';
import '../components/booking_card.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _TabLabel(label: 'Active', selected: false),
                _TabLabel(label: 'History', selected: true),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return BookingCard(booking: bookings[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String label;
  final bool selected;

  const _TabLabel({
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      borderRadius: AppRadii.lg,
      color: selected ? AppColors.primary.withOpacity(0.2) : null,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: selected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
