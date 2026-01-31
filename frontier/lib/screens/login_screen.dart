import 'package:flutter/material.dart';

import '../components/app_glass_card.dart';
import '../components/primary_button.dart';
import '../navigation/app_routes.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'demo');
  final _passwordController = TextEditingController(text: 'demo123');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                      _TextField(label: 'Email', controller: _emailController),
                      const SizedBox(height: AppSpacing.md),
                      _TextField(
                        label: 'Password',
                        obscure: true,
                        controller: _passwordController,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: _loading ? 'Signing in...' : 'Continue',
                        onPressed: _loading ? null : () => _handleLogin(context),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _error!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ],
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

  Future<void> _handleLogin(BuildContext context) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final success = await AuthService.login(
      username: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } else {
      setState(() {
        _loading = false;
        _error = 'Login failed. Check your credentials.';
      });
    }
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final bool obscure;
  final TextEditingController? controller;

  const _TextField({
    required this.label,
    this.obscure = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      controller: controller,
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
