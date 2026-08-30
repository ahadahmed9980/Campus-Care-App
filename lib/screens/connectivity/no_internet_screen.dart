import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/connectivity_controller.dart';
import '../../theme/app_theme.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final connectivityController = Get.find<ConnectivityController>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with breathing pulse animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.05, 1.05),
                duration: 1500.ms,
                curve: Curves.easeInOut,
              ),
              const SizedBox(height: 32),
              // Main title with fade/slide animation
              Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),
              const SizedBox(height: 12),
              // Message
              Text(
                'Your request cannot be processed right now.\nPlease check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark ? Colors.grey[400] : AppColors.textLight,
                ),
              )
              .animate()
              .fadeIn(delay: 150.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 150.ms, duration: 400.ms, curve: Curves.easeOutQuad),
              const SizedBox(height: 40),
              // Retry Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final connected = await connectivityController.checkCurrentConnection();
                    if (connected) {
                      Get.snackbar(
                        'Connected',
                        'Internet connection restored!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.success,
                        colorText: Colors.white,
                      );
                    } else {
                      Get.snackbar(
                        'Still Offline',
                        'Could not connect. Please check your settings.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.error,
                        colorText: Colors.white,
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 400.ms, curve: Curves.easeOutQuad),
            ],
          ),
        ),
      ),
    );
  }
}
