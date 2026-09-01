import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _emailSent = false;
  final _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _authController.sendPasswordReset(_emailCtrl.text.trim());
      if (mounted) setState(() => _emailSent = true);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.surface,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ── Back ──
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Header ──
                  Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textDark,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fade(duration: 350.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 8),
                  Text(
                    "No worries! Enter your university email and we'll send you a reset link.",
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.grey[400] : AppColors.textLight,
                      height: 1.5,
                    ),
                  ).animate().fade(duration: 350.ms, delay: 50.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 32),

                  if (!_emailSent) ...[
                    // ── Reset Form Icon ──
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock_reset_rounded,
                            size: 44,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ).animate().fade(duration: 350.ms, delay: 100.ms).scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.bounceOut),
                    const SizedBox(height: 32),

                    // ── Form ──
                    Form(
                      key: _formKey,
                      child: AppTextField(
                        label: 'University Email',
                        hint: '',
                        controller: _emailCtrl,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _sendReset,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!v.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ).animate().fade(duration: 350.ms, delay: 150.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 24),

                    Obx(
                      () => PrimaryButton(
                        label: 'Send Reset Link',
                        onPressed: _sendReset,
                        isLoading: _authController.isLoading.value,
                        icon: Icons.send_rounded,
                      ),
                    ).animate().fade(duration: 350.ms, delay: 200.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                  ] else ...[
                    // ── Success State ──
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF064E3B) : AppColors.successLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.mark_email_read_outlined,
                                size: 44,
                                color: AppColors.success,
                              ),
                            ),
                          ).animate().fade(duration: 350.ms).scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.bounceOut),
                          const SizedBox(height: 24),
                          Text(
                            'Check your email!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                          ).animate().fade(duration: 350.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 12),
                          Text(
                            'We sent a password reset link to\n${_emailCtrl.text}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[400] : AppColors.textLight,
                              height: 1.6,
                            ),
                          ).animate().fade(duration: 350.ms, delay: 150.ms).slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 32),
                          PrimaryButton(
                            label: 'Back to Login',
                            onPressed: () => Get.back(),
                          ).animate().fade(duration: 350.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => setState(() => _emailSent = false),
                            child: Text(
                              'Try a different email',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : AppColors.textLight,
                                fontSize: 14,
                              ),
                            ),
                          ).animate().fade(duration: 350.ms, delay: 250.ms),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}