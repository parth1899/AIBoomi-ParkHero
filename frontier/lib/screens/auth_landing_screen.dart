import 'package:flutter/material.dart';

import '../components/app_glass_card.dart';
import '../components/primary_button.dart';
import '../navigation/app_routes.dart';
import '../theme/app_theme.dart';

class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDAE9FF),
              Color(0xFFF1F6FF),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Smart Parking',
                  style: AppTextStyles.headline,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Book, navigate, and manage parking with a glass-smooth UI.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Get started', style: AppTextStyles.subtitle),
                      const SizedBox(height: AppSpacing.md),
                      PrimaryButton(
                        label: 'Login',
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.login,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.divider),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.signup,
                        ),
                        child: const Text('Sign up'),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.roleSelect,
                    ),
                    child: const Text('Continue as guest'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
