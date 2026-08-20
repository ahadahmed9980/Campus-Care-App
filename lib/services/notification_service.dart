import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background handler required by Firebase Messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message received: ${message.messageId}');

  if (message.notification != null) {
    await NotificationService.saveNotificationToFirestore(
      message.notification!.title ?? 'Notification',
      message.notification!.body ?? '',
    );
  }
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  void Function(RemoteMessage message)? onForegroundMessage;
  void Function(RemoteMessage message)? onMessageOpened;

  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        debugPrint('Skipping native FCM setup on web.');
        return;
      }

      final notificationSettings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (notificationSettings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
      }

      await _messaging.subscribeToTopic('all_students');
      await _initializeLocalNotifications();
      await _requestToken();

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedAppMessage);
    } catch (e) {
      debugPrint('Notification initialization failed: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);
  }

  Future<void> _requestToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
      }
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (message.notification == null) {
      return;
    }

    final title = message.notification!.title ?? 'Notification';
    final body = message.notification!.body ?? '';
    await saveNotificationToFirestore(title, body);

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'campus_care_channel',
          'Campus Care Alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: body,
    );

    onForegroundMessage?.call(message);
  }

  void _handleOpenedAppMessage(RemoteMessage message) {
    debugPrint('Notification clicked from background!');
    onMessageOpened?.call(message);
  }

  static Future<void> saveNotificationToFirestore(
    String title,
    String message,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving notification to Firestore: $e');
    }
  }

  Future<void> saveNotificationToFirestoreInstance(
    String title,
    String message,
  ) {
    return saveNotificationToFirestore(title, message);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await _messaging.subscribeToTopic('all_students');
      }
    } else {
      await _messaging.unsubscribeFromTopic('all_students');
    }
  }

  Future<bool> isTopicSubscribed(String topic) async {
    try {
      final token = await _messaging.getToken();
      return token != null;
    } catch (_) {
      return false;
    }
  }
}
