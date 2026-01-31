import 'package:flutter/material.dart';

import '../components/app_glass_card.dart';
import '../components/primary_button.dart';
import '../theme/app_theme.dart';

class SellerListSpotScreen extends StatefulWidget {
  const SellerListSpotScreen({super.key});

  @override
  State<SellerListSpotScreen> createState() => _SellerListSpotScreenState();
}

class _SellerListSpotScreenState extends State<SellerListSpotScreen> {
  final List<_SellerSpot> _spots = [
    _SellerSpot(
      name: 'Central Plaza Parking',
      address: '123 Market St, SF',
      pricePerHour: 4.0,
      isActive: true,
    ),
  ];

  void _showAddSpot() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final priceController = TextEditingController(text: '4.0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('List a spot', style: AppTextStyles.subtitle),
              const SizedBox(height: AppSpacing.md),
              _InputField(controller: nameController, label: 'Spot name'),
              const SizedBox(height: AppSpacing.md),
              _InputField(controller: addressController, label: 'Address'),
              const SizedBox(height: AppSpacing.md),
              _InputField(
                controller: priceController,
                label: 'Price per hour',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Add listing',
                onPressed: () {
                  final price = double.tryParse(priceController.text) ?? 0.0;
                  setState(() {
                    _spots.add(
                      _SellerSpot(
                        name: nameController.text,
                        address: addressController.text,
                        pricePerHour: price,
                        isActive: true,
                      ),
                    );
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            AppGlassCard(
              child: Row(
                children: const [
                  Icon(Icons.store_mall_directory, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('Your listed parking spots', style: AppTextStyles.subtitle),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.builder(
                itemCount: _spots.length,
                itemBuilder: (context, index) {
                  final spot = _spots[index];
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
                                spot.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(spot.address, style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        Text(
                          '\$${spot.pricePerHour.toStringAsFixed(2)}/hr',
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
            PrimaryButton(
              label: 'List new spot',
              onPressed: _showAddSpot,
            ),
          ],
        ),
      ),
    );
  }
}

class _SellerSpot {
  final String name;
  final String address;
  final double pricePerHour;
  final bool isActive;

  _SellerSpot({
    required this.name,
    required this.address,
    required this.pricePerHour,
    required this.isActive,
  });
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
      ),
    );
  }
}
