import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _navigateNext();
    });
  }

  Future<void> _navigateNext() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is logged in, navigate straight to AuthWrapper (Home wrapper)
      Get.offNamed(AppRoutes.authWrapper);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hasSeenGetStarted = prefs.getBool('hasSeenGetStarted') ?? false;

    if (hasSeenGetStarted) {
      Get.offNamed(AppRoutes.authWrapper);
    } else {
      Get.offNamed(AppRoutes.getStarted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.school_rounded,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
            ).animate().fade(duration: 500.ms).scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.bounceOut),
            const SizedBox(height: 24),
            const Text(
              'Campus Care',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ).animate().fade(duration: 400.ms, delay: 300.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: 8),
            Text(
              'Student Service Portal',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ).animate().fade(duration: 400.ms, delay: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}
