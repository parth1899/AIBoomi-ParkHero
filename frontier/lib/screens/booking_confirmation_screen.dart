import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../navigation/app_routes.dart';
import '../components/primary_button.dart';
import '../theme/app_theme.dart';
import '../types/models.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD7E9FF),
              Color(0xFFEAF2FF),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Share'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 42,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Booking Confirmed',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your spot at ${booking.lotName} is reserved for today.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
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
                  child: Column(
                    children: [
                      QrImageView(
                        data: booking.qrPayload ?? booking.accessCode ?? booking.id,
                        size: 140,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Scan to enter',
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Hold your phone near the scanner',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DetailItem(label: 'DATE', value: booking.dateLabel),
                      _DetailItem(label: 'SPOT', value: booking.spotLabel),
                      _DetailItem(label: 'LEVEL', value: booking.floor),
                    ],
                  ),
                ),
                const Spacer(),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Get Directions',
                      onPressed: () {
                        if (booking.latitude != null && booking.longitude != null) {
                          // Construct a minimal ParkingLot for navigation
                          final lot = ParkingLot(
                            id: 'nav_temp',
                            name: booking.lotName,
                            address: '', // Not needed for nav
                            areaTags: [],
                            latitude: booking.latitude!,
                            longitude: booking.longitude!,
                            pricePerHour: 0,
                            rating: 0,
                            reviewCount: 0,
                            distance: '',
                            availabilityLabel: '',
                            isOpen: true,
                            imageAsset: '',
                            amenities: [],
                            floors: [],
                          );
                          Navigator.pushNamed(
                            context,
                            AppRoutes.navigation,
                            arguments: lot,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Location unavailable')),
                          );
                        }
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Need help? ', style: AppTextStyles.caption),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Contact Support',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ],
    );
  }
}
