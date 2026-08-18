import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes/app_routes.dart';
import '../services/notification_service.dart';
import '../utils/preferences_keys.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService;

  NotificationController(this._notificationService);

  final isNotificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _wireServiceCallbacks();
    _loadNotificationPreference();
  }

  @override
  void onReady() {
    super.onReady();
    initializeNotifications();
    handleInitialMessage();
  }

  void _wireServiceCallbacks() {
    _notificationService.onForegroundMessage = _onForegroundMessage;
    _notificationService.onMessageOpened = _onMessageOpened;
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    isNotificationsEnabled.value =
        prefs.getBool(PreferencesKeys.pushNotifications) ?? true;
  }

  Future<void> initializeNotifications() async {
    await _notificationService.initialize();
    if (isNotificationsEnabled.value) {
      isNotificationsEnabled.value = await _notificationService
          .isTopicSubscribed('all_students');
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    try {
      await _notificationService.setNotificationsEnabled(enabled);
      isNotificationsEnabled.value = enabled;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PreferencesKeys.pushNotifications, enabled);

      if (enabled) {
        Get.snackbar(
          'Notifications enabled',
          'You are now subscribed to campus alerts.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Notification update failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    if (message.notification == null) {
      return;
    }

    final title = message.notification!.title ?? 'Notification';
    final body = message.notification!.body ?? '';

    if (Get.context != null) {
      await Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('OK')),
          ],
        ),
      );
    }
  }

  Future<void> _onMessageOpened(RemoteMessage message) async {
    navigateToNotificationsScreen();
  }

  Future<void> handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      debugPrint('App opened from terminated state by notification!');
      Future.delayed(const Duration(milliseconds: 500), () {
        navigateToNotificationsScreen();
      });
    }
  }

  void navigateToNotificationsScreen() {
    if (Get.currentRoute != AppRoutes.notifications) {
      Get.toNamed(AppRoutes.notifications);
    }
  }
}
