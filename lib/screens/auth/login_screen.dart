import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authController = Get.find<AuthController>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                          Icons.school_rounded,
                          size: 70,
                          color: AppColors.primary,
                        )
                        .animate()
                        .fade(duration: 350.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 16),
                    Text(
                          'Campus Care',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        )
                        .animate()
                        .fade(duration: 350.ms, delay: 50.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 32),
                    TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: isDark ? Colors.grey[400] : null,
                            ),
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Enter email' : null,
                        )
                        .animate()
                        .fade(duration: 350.ms, delay: 100.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 16),
                    TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: isDark ? Colors.grey[400] : null,
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: isDark ? Colors.grey[400] : null,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Enter password'
                              : null,
                        )
                        .animate()
                        .fade(duration: 350.ms, delay: 150.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 8),
                    Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                Get.toNamed(AppRoutes.forgotPassword),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fade(duration: 350.ms, delay: 180.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 16),
                    Obx(
                          () => ElevatedButton(
                            onPressed: _authController.isLoading.value
                                ? null
                                : () {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    _authController.login(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim(),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _authController.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        )
                        .animate()
                        .fade(duration: 350.ms, delay: 220.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 16),
                    Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDark ? Colors.grey[700] : null,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : AppColors.textLight,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDark ? Colors.grey[700] : null,
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .fade(duration: 350.ms, delay: 260.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 16),
                    Obx(
                          () => OutlinedButton.icon(
                            onPressed:
                                _authController.isGoogleLoading.value ||
                                    _authController.isLoading.value
                                ? null
                                : _authController.signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: isDark ? Colors.grey[700]! : Colors.grey,
                              ),
                            ),
                            icon: Image.asset(
                              'assets/images/goog.png',
                              width: 24,
                              height: 24,
                            ),
                            label: Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fade(duration: 350.ms, delay: 300.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 24),
                    Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : AppColors.textLight,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed(AppRoutes.register),
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .fade(duration: 350.ms, delay: 340.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
