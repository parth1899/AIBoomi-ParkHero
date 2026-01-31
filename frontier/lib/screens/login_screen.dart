import 'package:flutter/material.dart';

import '../components/app_glass_card.dart';
import '../components/primary_button.dart';
import '../navigation/app_routes.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE2EEFF),
              Color(0xFFF4F8FF),
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
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Welcome back', style: AppTextStyles.headline),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to continue to your parking dashboard.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _TextField(label: 'Email'),
                      const SizedBox(height: AppSpacing.md),
                      const _TextField(label: 'Password', obscure: true),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: 'Continue',
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                          (route) => false,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.signup,
                          ),
                          child: const Text('Create an account'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Center(
                  child: Text(
                    'Apple‑style privacy. Your data stays on device.',
                    style: AppTextStyles.caption,
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

class _TextField extends StatelessWidget {
  final String label;
  final bool obscure;

  const _TextField({
    required this.label,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
      ),
    );
  }
}
