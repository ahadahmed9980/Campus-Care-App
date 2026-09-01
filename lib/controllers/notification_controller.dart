import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';
import '../routes/app_routes.dart';
import '../services/notification_service.dart';
import '../utils/preferences_keys.dart';
import 'connectivity_controller.dart';

class NotificationController extends GetxController {
  NotificationController(
    this._notificationService,
    this._notificationRepository,
  );

  final NotificationService _notificationService;
  final NotificationRepository _notificationRepository;

  final isNotificationsEnabled = true.obs;

  final notifications = <CampusNotification>[].obs;

  final isLoading = true.obs;

  final errorMessage = RxnString();
  final isMarkingAllRead = false.obs;

  Stream<List<CampusNotification>>? _notificationStream;
  StreamSubscription<List<CampusNotification>>? _notificationSubscription;

  @override
  void onInit() {
    super.onInit();

    _wireServiceCallbacks();
    _loadNotificationPreference();
    _startNotificationStream();
  }

  @override
  void onReady() {
    super.onReady();

    initializeNotifications();

    if (!kIsWeb) {
      handleInitialMessage();
    }
  }

  void _wireServiceCallbacks() {
    _notificationService.onForegroundMessage = _onForegroundMessage;
    _notificationService.onMessageOpened = _onMessageOpened;
  }

  void _startNotificationStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      isLoading.value = false;
      notifications.clear();
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    _notificationSubscription?.cancel();
    _notificationStream =
        _notificationRepository.watchUserNotifications(user.uid);

    _notificationSubscription = _notificationStream!.listen(
      (items) {
        notifications.assignAll(items);
        isLoading.value = false;
        errorMessage.value = null;
      },
      onError: (error) {
        isLoading.value = false;
        errorMessage.value = 'Unable to load notifications.';
      },
    );
  }

  int get unreadCount {
    return notifications.where((item) => !item.isRead).length;
  }

  List<CampusNotification> get unreadNotifications {
    return notifications.where((item) => !item.isRead).toList();
  }

  Future<void> markAsRead(CampusNotification notification) async {
    if (notification.isRead) {
      return;
    }

    if (Get.isRegistered<ConnectivityController>()) {
      final conn = Get.find<ConnectivityController>();
      if (!conn.isConnected.value) {
        return;
      }
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      await _notificationRepository.markAsRead(
        userId: user.uid,
        notificationId: notification.id,
      );

      final index = notifications.indexWhere(
        (item) => item.id == notification.id,
      );

      if (index != -1) {
        notifications[index] = notification.copyWith(
          isRead: true,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Unable to update notification',
        'Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final unreadIds = unreadNotifications
        .map((notification) => notification.id)
        .toList();

    if (unreadIds.isEmpty) {
      return;
    }

    if (Get.isRegistered<ConnectivityController>()) {
      final conn = Get.find<ConnectivityController>();
      if (!conn.isConnected.value) {
        Get.snackbar(
          'No Internet Connection',
          'Please check your internet connection and try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
        );
        return;
      }
    }

    if (isMarkingAllRead.value) return;
    isMarkingAllRead.value = true;

    try {
      await _notificationRepository.markAllAsRead(
        userId: user.uid,
        notificationIds: unreadIds,
      );

      notifications.assignAll(
        notifications.map(
          (notification) => notification.copyWith(
            isRead: true,
          ),
        ),
      );

      Get.snackbar(
        'Notifications updated',
        'All notifications have been marked as read.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Unable to update notifications',
        'Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isMarkingAllRead.value = false;
    }
  }

  Future<void> reload() async {
    _startNotificationStream();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();

    isNotificationsEnabled.value =
        prefs.getBool(PreferencesKeys.pushNotifications) ?? true;
  }

  Future<void> initializeNotifications() async {
    await _notificationService.initialize();

    if (isNotificationsEnabled.value) {
      isNotificationsEnabled.value =
          await _notificationService.isTopicSubscribed('all_students');
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    try {
      await _notificationService.setNotificationsEnabled(enabled);

      isNotificationsEnabled.value = enabled;

      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
        PreferencesKeys.pushNotifications,
        enabled,
      );

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

  Future<void> _onForegroundMessage(
    RemoteMessage message,
  ) async {
    if (message.notification == null) {
      return;
    }

    final title =
        message.notification!.title ?? 'Notification';

    final body =
        message.notification!.body ?? '';

    if (Get.context != null) {
      await Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _onMessageOpened(
    RemoteMessage message,
  ) async {
    navigateToNotificationsScreen();
  }

  Future<void> handleInitialMessage() async {
    final message =
        await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      Future.delayed(
        const Duration(milliseconds: 500),
        navigateToNotificationsScreen,
      );
    }
  }

  void navigateToNotificationsScreen() {
    if (Get.currentRoute != AppRoutes.notifications) {
      Get.toNamed(AppRoutes.notifications);
    }
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    _notificationService.onForegroundMessage = null;
    _notificationService.onMessageOpened = null;
    super.onClose();
  }
}