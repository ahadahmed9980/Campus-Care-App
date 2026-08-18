import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/preferences_keys.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find<ThemeController>();

  final themeMode = ThemeMode.light.obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(PreferencesKeys.isDarkMode) ?? false;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);
  }

  Future<void> toggleTheme(bool isDark) async {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferencesKeys.isDarkMode, isDark);
  }
}
