import 'package:flutter/material.dart';

import '../components/app_glass_card.dart';
import '../components/primary_button.dart';
import '../navigation/app_routes.dart';
import '../theme/app_theme.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
                const Text('Create your account', style: AppTextStyles.headline),
                const SizedBox(height: 6),
                const Text(
                  'Set up your profile in minutes.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppGlassCard(
                  child: const _SignupForm(),
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

class _SignupForm extends StatefulWidget {
  const _SignupForm();

  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  String _role = 'consumer';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TextField(label: 'Full name'),
        const SizedBox(height: AppSpacing.md),
        const _TextField(label: 'Email'),
        const SizedBox(height: AppSpacing.md),
        const _TextField(label: 'Password', obscure: true),
        const SizedBox(height: AppSpacing.md),
        const Text('Account type', style: AppTextStyles.subtitle),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _RolePill(
              label: 'Consumer',
              selected: _role == 'consumer',
              onTap: () => setState(() => _role = 'consumer'),
            ),
            const SizedBox(width: 10),
            _RolePill(
              label: 'Seller',
              selected: _role == 'seller',
              onTap: () => setState(() => _role = 'seller'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Create account',
          onPressed: () {
            if (_role == 'seller') {
              Navigator.pushNamed(context, AppRoutes.sellerListing);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.login,
            ),
            child: const Text('I already have an account'),
          ),
        ),
      ],
    );
  }
}

class _RolePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RolePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: selected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
