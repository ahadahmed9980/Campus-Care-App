import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class NotificationRepository {
  NotificationRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _notifications(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  Stream<List<CampusNotification>> watchUserNotifications(
    String userId,
  ) {
    return _notifications(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs
          .map(CampusNotification.fromDoc)
          .where(_isNotExpired)
          .toList();

      return notifications;
    });
  }

  bool _isNotExpired(CampusNotification notification) {
    final expiresAt = notification.expiresAt;

    if (expiresAt == null) {
      return true;
    }

    return expiresAt.isAfter(DateTime.now());
  }

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    await _notifications(userId)
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead({
    required String userId,
    required List<String> notificationIds,
  }) async {
    if (notificationIds.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final notificationId in notificationIds) {
      batch.update(
        _notifications(userId).doc(notificationId),
        {
          'isRead': true,
        },
      );
    }

    await batch.commit();
  }
}