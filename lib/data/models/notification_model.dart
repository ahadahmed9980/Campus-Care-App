import 'package:cloud_firestore/cloud_firestore.dart';

class CampusNotification {
  const CampusNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.requestId,
    this.createdAt,
    this.expiresAt,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? requestId;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  factory CampusNotification.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    return CampusNotification(
      id: doc.id,
      title: data['title'] as String? ?? 'Notification',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      isRead: data['isRead'] as bool? ?? false,
      requestId: data['requestId'] as String?,
      createdAt: _parseDate(data['createdAt']),
      expiresAt: _parseDate(data['expiresAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  CampusNotification copyWith({
    bool? isRead,
  }) {
    return CampusNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      requestId: requestId,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }
}