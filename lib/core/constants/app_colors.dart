import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/theme_controller.dart';

/// CampusCare design tokens used by dashboard and request screens.
class AppColors {
  AppColors._();

  static bool get _isDark {
    try {
      final context = Get.context;
      if (context != null) {
        return Theme.of(context).brightness == Brightness.dark;
      }
      if (Get.isRegistered<ThemeController>()) {
        return Get.find<ThemeController>().themeMode.value == ThemeMode.dark;
      }
    } catch (_) {}
    return Get.isDarkMode;
  }

  static const Color primary = Color(0xFF1B6B4A);
  static const Color primaryDark = Color(0xFF145239);
  static const Color primaryLight = Color(0xFFE7F4EE);
  static const Color accent = Color(0xFF2E8B63);

  static Color get background => _isDark ? const Color(0xFF121212) : const Color(0xFFF3F5F7);
  static Color get surface => _isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  static Color get border => _isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE4E8EC);

  static Color get textPrimary => _isDark ? const Color(0xFFE0E0E0) : const Color(0xFF1A1D21);
  static Color get textSecondary => _isDark ? const Color(0xFF8A8F8E) : const Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color open = Color(0xFF1B6B4A);
  static const Color inProgress = Color(0xFFE29A12);
  static const Color underReview = Color(0xFF3B82F6);
  static const Color resolved = Color(0xFF2563EB);
  static const Color rejected = Color(0xFFE53935);
  static const Color announcement = Color(0xFF7C5CBF);
  static const Color highPriority = Color(0xFFE53935);
  static const Color mediumPriority = Color(0xFFE29A12);
  static const Color lowPriority = Color(0xFF2E8B63);

  static const Color success = Color(0xFF1B6B4A);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFE29A12);
}

